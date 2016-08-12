class DocumentParserJob
  include SuckerPunch::Job

  ACCEPTABLE_ALPHABET_RATIO = 0.9

  def perform(document)
    unless Rails.env.test?
      dir = document.clean_url.split('/')[0...-1].join('/')
      puts 'ocr-ing...'
      Docsplit.extract_text(document.clean_url, output: dir, ocr: true)
      content = File.read(document.url_text)
      content.gsub!(/\?/, ' ')
      File.write(document.url_text, content)
      puts 'ocr done...'

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
        content.each_line do |line|
          next if line =~ /^Chapter \d\./i || line.blank?

          processed_line = line.downcase.gsub(/\s/, '')
          if processed_line.include?(prefix_section)
            content_page = contents_passed
            contents_passed = true
          end

          next unless content_page

          section_number_regex = /^\d(\.\d)+\.?/
          if processed_line =~ section_number_regex
            save_section(document, prev_section_number, prev_section_name, prev_content)
            prev_content = ''
            prev_section_number = processed_line.match(section_number_regex)[0]
            prev_section_name = line.slice(line.index(/[A-Za-z]/)..-1)
          else
            prev_content += line
          end
        end

        # process last section after reading last line
        save_section(document, prev_section_number, prev_section_name, prev_content)
      end

      begin
        document.sections.add_section(section_number: '-', section_name: 'Full Content', content: content)
      rescue Searchkick::ImportError
        puts "too long, not indexed"
      end
    end

    document.finish_parsing!
  end

  def save_section(document, prev_section_number, prev_section_name, prev_content)
    content_exists = prev_section_number.present?
    content_exists &&= prev_section_name.present?
    content_exists &&= prev_content.present?
    content_exists && document.sections.add_section(section_number: prev_section_number, section_name: prev_section_name, content: prev_content)
  rescue Searchkick::ImportError
    puts "too long, not indexed"
  end
end
