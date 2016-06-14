require 'open-uri'

class DocumentParserJob
  include SuckerPunch::Job

  def perform(document)
    reader = PDF::Reader.new(open(document.url))
    puts reader.info
    document
  end
end
