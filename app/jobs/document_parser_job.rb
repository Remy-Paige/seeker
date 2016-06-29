require 'open-uri'

class DocumentParserJob
  include SuckerPunch::Job

  ACCEPTABLE_ALPHABET_RATIO = 0.9

  def perform(document)
    dir = document.clean_url.split('/')[0...-1].join('/')
    FileUtils.mkdir_p(dir)
    IO.copy_stream(open(document.url), document.clean_url)

    # no ocr for better parsing
    Docsplit.extract_text(document.clean_url, output: dir, no_ocr: true)

    # check no ocr content
    no_ocr_result = File.read(document.url_text)
    alphabet_count = 0
    no_ocr_result.split('').each do |chr|
      alphabet_count += 1 if chr =~ /[A-Za-z., \n\r]/
    end
    alphabet_ratio = alphabet_count * 1.0 / no_ocr_result.length

    # ocr if gibberish suspected
    Docsplit.extract_text(document.clean_url, output: dir, ocr: true) if alphabet_ratio < ACCEPTABLE_ALPHABET_RATIO

    document
  end
end
