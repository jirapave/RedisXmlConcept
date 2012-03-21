if File.basename($0) == "#{File.basename(__FILE__)}"
  require_relative "../../lib/redxml.rb"
else
  require "redxml"
end
require "test/unit"

class TestDocumentService < Test::Unit::TestCase
  
  FILE_PATH = "#{__FILE__}/../catalog.xml"
  
  def setup()
    DBInit.init_database
    @db_interface = BaseInterface::DBInterface.instance
    @coll_service = Transformer::CollectionService.new("1")
    @doc_service = Transformer::DocumentService.new("1", "4")
  end
  
  #TODO Unit tests for document_service
end