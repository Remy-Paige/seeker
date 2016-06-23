require 'open-uri'

class DocumentParserJob
  include SuckerPunch::Job

  def perform(document)
    dir = document.clean_url.split('/')[0...-1].join('/')
    FileUtils.mkdir_p(dir)
    IO.copy_stream(open(document.url), document.clean_url)
    Docsplit.extract_text(document.clean_url, output: dir, ocr: true)
    document
  end
end
