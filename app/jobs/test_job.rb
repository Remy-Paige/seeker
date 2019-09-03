class TestJob
  include SuckerPunch::Job
  require 'hexapdf'
  require 'hexapdf/cli'
  
  def perform(document)

    puts('test_hexa')
    # hexa error undefined method `sub' for #<Document:0x00561ed8225d60>
    #       # doc = HexaPDF::Document.open(document.clean_url)
    #       # split = HexaPDF::CLI::Split.new
    #       # split.execute(document.clean_url)
    #




  end
end
