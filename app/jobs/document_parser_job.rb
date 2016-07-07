require 'open-uri'

class DocumentParserJob
  include SuckerPunch::Job

  ACCEPTABLE_ALPHABET_RATIO = 0.9

  def perform(document)
    dir = document.clean_url.split('/')[0...-1].join('/')
    FileUtils.mkdir_p(dir)
    IO.copy_stream(open(document.url), document.clean_url)

    # no ocr for faster parsing
    Docsplit.extract_text(document.clean_url, output: dir, no_ocr: true)
    puts 'no_ocr done...'

    # check no ocr content if properly parsed or gibberish
    content = File.read(document.url_text)
    alphabet_count = 0
    content.split('').each do |chr|
      alphabet_count += 1 if chr =~ /[A-Za-z.,:; \n\r]/
    end
    alphabet_ratio = alphabet_count * 1.0 / content.length

    # ocr if gibberish suspected
    puts "ratio is #{alphabet_ratio}"
    if alphabet_ratio < ACCEPTABLE_ALPHABET_RATIO
      puts 'ocr-ing...'
      Docsplit.extract_text(document.clean_url, output: dir, ocr: true)
      content = File.read(document.url_text)
      content.gsub!(/\?/, ' ')
      File.write(document.url_text, content)
      puts 'ocr done...'
    end

    document.sections.create(section_name: 'General Content', content: content)

    document.finish_parsing!
  end
end
