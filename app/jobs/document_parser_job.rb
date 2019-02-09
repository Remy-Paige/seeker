class DocumentParserJob
  include SuckerPunch::Job
  workers 1

  ACCEPTABLE_ALPHABET_RATIO = 0.9

  def perform(document)
    @doc = document
    @l = Logger.new("#{Rails.root}/log/parser.log")
    write_to_log('start perform')
    unless Rails.env.test?
      original_url = document.url
      clean_url = document.clean_url
      text_url = document.url_text

      dir = document.clean_url.split('/')[0...-1].join('/')
      write_to_log('ocr-ing...')
      logger.info 'Start OCR'
      logger.info 'clean' + document.clean_url
      logger.info 'text' + document.url_text
      begin
        Docsplit.extract_text(document.clean_url, output: dir, ocr: true, pages: 'all')
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

      # 'path'
      document_name = file_name[0, file_name.rindex('.txt')]
      page_number = 1
      # 'path_1.txt'
      # docsplit starts page file creation at 1
      document_page_file_name = document_name + "_" + page_number.to_s + ".txt"

      while File.exists?(document_page_file_name) do

        # File.open(document_file, 'a') { |file| file.write("your text") }

        File.open(document_page_file_name, 'rb') do |input_stream|
          File.open(document_file, 'ab') do |output_stream|
            IO.copy_stream(input_stream, output_stream)
          end
        end

        File.delete(document_page_file_name)

        page_number = page_number + 1
        document_page_file_name = document_name + "_" + page_number.to_s + ".txt"
      end

      # while file_xx.txt exists
      #
      #   append file_xx.txt to file.txt
      #   erase file_xx.txt
      #   increment XX


      content = File.read(document.url_text)

      # ? is backslash escaped to match it literally
      # the exclamation mark indicated that content itself is being modified
      content.gsub!(/\?/, ' ')
      File.write(document.url_text, content)
      write_to_log('ocr done...')

      # fix new lines after numbering
      content.gsub!(/^((\d|\w)\.)+[\n\r]+/mi, '\1 ')



      # separate committee of experts report sections automatically
      # documents not following the rules may not be parsed correctly
      if Document::DOCUMENT_TYPES[document.document_type] == 'Committee of Experts Report'
        prefix_section = 'report of the committee of experts on the application of the charter'.gsub(/\s/, '')
        content_page = false
        contents_passed = false
        prev_line = nil
        prev_content = ''
        prev_section_number = ''
        prev_section_name = ''
        current_page = 2
        prev_page = 2
        content.each_line do |line|
          next if line =~ /^Chapter \d\./i || line.blank?

          processed_line = line.downcase.gsub(/\s/, '')

          #my code
          # the page numbers turn up as this special character
          if line.include?("\f")
            current_page = current_page + 1
          end
          #end my code

          if processed_line.include?(prefix_section)
            content_page = contents_passed
            contents_passed = true
          end

          next unless content_page

          section_number_regex = /^\d(\.\d)+\.?/
          if processed_line =~ section_number_regex
            save_section(document, prev_section_number, prev_section_name, prev_content, prev_page)
            prev_content = ''
            prev_section_number = processed_line.match(section_number_regex)[0]
            prev_section_name = line.slice(line.index(/[A-Za-z]/)..-1)
            prev_page = current_page
          else
            prev_content += line
          end
        end

        # process last section after reading last line
        save_section(document, prev_section_number, prev_section_name, prev_content, prev_page)
      end

      begin
        document.sections.add_section(section_number: '-', section_name: 'Full Content', content: content, page_number: 0)
      rescue Searchkick::ImportError
        write_to_log("too long, not indexed")
      end
    end

    write_to_log('parsing finished')
    document.finish_parsing!
  rescue StandardError => e
    write_to_log('what1')
    logger.info 'Failure'
    document.status = 1
    document.save
    raise e
  end


  def save_section(document, prev_section_number, prev_section_name, prev_content, current_page)
    content_exists = prev_section_number.present?
    content_exists &&= prev_section_name.present?
    content_exists &&= prev_content.present?
    content_exists &&= current_page.present?
    content_exists && document.sections.add_section(section_number: prev_section_number, section_name: prev_section_name, content: prev_content, page_number: current_page)
  rescue Searchkick::ImportError
    write_to_log("too long, not indexed")
  end

  def write_to_log(message)
    @l.info(@doc.inspect)
    @l.info(message)
  end
end
