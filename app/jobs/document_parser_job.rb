class DocumentParserJob
  include SuckerPunch::Job
  require 'hexapdf'
  require 'hexapdf/cli'
  workers 1

  ACCEPTABLE_ALPHABET_RATIO = 0.9

  def perform(document)
    @doc = document
    @l = Logger.new("#{Rails.root}/log/parser.log")
    write_to_log('start perform')
    unless Rails.env.test?

      write_to_log('ocr-ing...')
      logger.info 'Start OCR'
      logger.info 'clean' + document.clean_url
      logger.info 'text' + document.url_text

      begin
        # start splitting the document into parts
        HexaPDF::CLI.run(args =["split", document.clean_url])

        # disassemble file path
        dir = document.clean_url.split('/')[0...-1].join('/')
        raw_file_path = document.clean_url.chomp('.pdf')
        i = 1
        while true do
          # count up numbers and turn the path parts and numbers into file names that match the files hexapdf creates
          if i > 999
            number = '_' + i.to_s
          elsif i > 99
            number = '_0' + i.to_s
          elsif i > 9
            number = '_00' + i.to_s
          else
            number = '_000' + i.to_s
          end
          # reassemble file path
          part_file_path = raw_file_path + number + '.pdf'
          # if the pdf file exists, process it into a 'one page' text file
          if File.file?(part_file_path)
            # create text part files from pdf part files
            Docsplit.extract_text(part_file_path, output: dir, ocr: true)
          else
            break
          end

          i = i + 1
        end

      rescue StandardError => e
        logger.info 'DocsplitError' + e.message
        raise 'Something went wrong with DocSplit'
      end
        write_to_log('finished ocr-ing...')
      logger.info 'Finish OCR'

      #clean_url can have .pdf at the end sometimes. url_text is stable
      # 'path.txt'
      file_name = document.url_text
      #a+ - Read-write, each write call appends data at end of file.
      # Creates a new file for reading and writing if file does not exist.
      document_file = File.new(file_name, "a+")

      # reassemble text file from parts
      page_number = 1
      while true do
        # count up numbers like before
        if page_number > 999
          number = '_' + page_number.to_s
        elsif page_number > 99
          number = '_0' + page_number.to_s
        elsif page_number > 9
          number = '_00' + page_number.to_s
        else
          number = '_000' + page_number.to_s
        end
        document_page_file_name = raw_file_path + number + '.txt'
        part_file_path = raw_file_path + number + '.pdf'

        puts document_page_file_name

        # if the file exists, write its contents to the end of the master file
        #   there might be a bug where if the file is added again,
        #   the old txt file is not deleted and the material is added onto the end
        # delete both .pdf and .txt part files
        if File.file?(document_page_file_name)
          File.open(document_page_file_name, 'rb') do |input_stream|
            File.open(document_file, 'ab') do |output_stream|
              IO.copy_stream(input_stream, output_stream)
            end
          end
          open(document_file, 'a') { |f|
            f.puts 'page number: ' + page_number.to_s
          }
          File.delete(document_page_file_name)
          File.delete(part_file_path)
        else
          break
        end
        page_number = page_number + 1
      end

      content = File.read(document.url_text)

      # ? is backslash escaped to match it literally
      # the exclamation mark indicated that content itself is being modified
      content.gsub!(/\?/, ' ')
      File.write(document.url_text, content)
      write_to_log('ocr done...')

      # fix new lines after numbering
      content.gsub!(/^((\d|\w)\.)+[\n\r]+/mi, '\1 ')
      logger.info 'start sectioning'
      SectionDocumentJob.perform_async(document)
      # separate committee of experts report sections automatically
      # documents not following the rules may not be parsed correctly

    end


  rescue StandardError => e
    write_to_log('what1')
    logger.info 'Failure'
    document.status = 1
    document.save
    raise e
  end

  def write_to_log(message)
    @l.info(@doc.inspect)
    @l.info(message)
  end
end
