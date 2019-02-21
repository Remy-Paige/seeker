class SectionDocumentJob 
  include SuckerPunch::Job
  
  def perform(document, content)

    document&.sections&.map(&:destroy)

    if Document::DOCUMENT_TYPES[document.document_type] == 'Committee of Experts Report'
      prefix_section = 'report of the committee of experts on the application of the charter'.gsub(/\s/, '')
      content_page = false
      contents_passed = false
      prev_line = nil
      prev_content = ''
      prev_section_number = ''
      prev_section_name = ''
      current_page = 1
      prev_page = 1
      content.each_line do |line|

        next if line =~ /^Chapter \d\./i || line.blank?

        processed_line = line.downcase.gsub(/\s/, '')
        logger.info processed_line
        #my code
        # match start line, digits, end line
        page_number = line[/^\d+$/].to_i

        if page_number != nil && page_number > current_page
          current_page = page_number
        end
        #end my code

        if processed_line.include?(prefix_section)
          content_page = contents_passed
          contents_passed = true
          logger.info 'includes prefix'
        end
        logger.info 'content_page' + content_page.to_s
        next unless content_page

        section_number_regex = /^\d(\.\d)+\.?/
        if processed_line =~ section_number_regex
          logger.info 'section'
          save_section(document, prev_section_number, prev_section_name, prev_content, prev_page + 1)
          prev_content = ''
          prev_section_number = processed_line.match(section_number_regex)[0]
          prev_section_name = line.slice(line.index(/[A-Za-z]/)..-1)
          prev_page = current_page
        else
          prev_content += line
        end
      end
      # prev page + 1 because of a tick over problem TODO: fix the hack
      # process last section after reading last line
      save_section(document, prev_section_number, prev_section_name, prev_content, prev_page + 1)
    end

    begin
      document.sections.add_section(section_number: '-', section_name: 'Full Content', content: content, page_number: 0, languages: nil, strengths: nil)
    rescue Searchkick::ImportError
      logger.info 'too long, not indexed'
    end

    logger.info 'start language parsing'
    LanguageParserJob.perform_in(60, document.id)

  rescue StandardError => e
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
    content_exists && document.sections.add_section(section_number: prev_section_number, section_name: prev_section_name, content: prev_content, page_number: current_page, languages: nil, strengths: nil)
  rescue Searchkick::ImportError
    logger.info 'too long, not indexed'
  end

end
