if File.basename($0) == "#{File.basename(__FILE__)}"
  require_relative "../../lib/redxml.rb"
elsif File.basename($0) == "generate_coverage.rb"
else
  require "redxml"
end
require "test/unit"

class TestDocumentService < Test::Unit::TestCase

  FILE_PATH = "#{__FILE__}/../catalog-ns.xml"
  def setup()
    DBInit.init_database
    @db_interface = BaseInterface::DBInterface.instance
    @coll_service = Transformer::CollectionService.new("1")
    @doc_service = Transformer::DocumentService.new("1", "2")
  end

  def test_get_possible_id
    id = @doc_service.get_possible_id.to_i
    id2 = @doc_service.get_possible_id.to_i
    id3 = @doc_service.get_possible_id.to_i
    assert_equal(true, (id + 1) == id2)
    assert_equal(true, (id2 + 1) == id3)
  end

  def test_save_document
    file = File.absolute_path(FILE_PATH)
    @doc_service.save_document(file)
    doc = @doc_service.find_document(File.basename(file))
    result = doc.xpath("//a:product/colorChoices").first
    assert_equal(true, "#{result}" == "<colorChoices attr:language=\"english\">navy black</colorChoices>")
  end

  def test_find_document
    file = File.absolute_path(FILE_PATH)
    @doc_service.save_document(file)
    doc = @doc_service.find_document(File.basename(file))
    result = doc.xpath("//a:product")
    assert_equal(true, result.length == 4)
    result = doc.xpath("//a:product/colorChoices").first
    assert_equal(true, "#{result}" == "<colorChoices attr:language=\"english\">navy black</colorChoices>")
  end

  def test_save_resource
    file = File.absolute_path(FILE_PATH)
    coll = XMLDBApi::RedCollection.new("1", "2", "coll")
    res = coll.create_resource("test_only", XMLDBApi::RedXmlResource::TYPE)
    res.set_content_as_dom(Nokogiri::XML(File.open(file)))
    @doc_service.save_resource(res)
    #@doc_service.save_document(file)
    doc = @doc_service.find_document("test_only")
    result = doc.xpath("//a:product")
    assert_equal(true, result.length == 4)
    result = doc.xpath("//a:product/colorChoices").first
    assert_equal(true, "#{result}" == "<colorChoices attr:language=\"english\">navy black</colorChoices>")
  end

  def test_get_resource
    file = File.absolute_path(FILE_PATH)
    @doc_service.save_document(file)
    name = File.basename(file)
    res = @doc_service.get_resource(name)
    doc = res.get_content_as_dom
    result = doc.xpath("//a:product")
    assert_equal(true, result.length == 4)
    result = doc.xpath("//a:product/colorChoices").first
    assert_equal(true, "#{result}" == "<colorChoices attr:language=\"english\">navy black</colorChoices>")
  end
  
  def test_move_resource
    coll = XMLDBApi::RedCollection.new("1", "2", "coll")
    res = coll.create_resource("moving_res", XMLDBApi::RedXmlResource::TYPE)
    res.set_content("<root><something>Let's move it</something></root>")
    @doc_service.save_resource(res)
    res = @doc_service.get_resource("moving_res")
    assert_equal(true, res.get_document_id == "moving_res")
    assert_equal(true, res.coll_id == "2")
    number_of_keys = @db_interface.find_keys("*").length
    @doc_service.move_resource(res, "5") #move to cfifth collection
    assert_equal(true, res.coll_id == "5")
    assert_raise Transformer::MappingException do
      res = @doc_service.get_resource("moving_res")
    end
    @doc_service = Transformer::DocumentService.new("1", "5")
    res = @doc_service.get_resource("moving_res")
    assert_equal(true, res.get_document_id == "moving_res")
    result = "#{res.get_content_as_dom.xpath("//something").first}"
    assert_equal(true, result == "<something>Let's move it</something>")
    final_number_of_keys = @db_interface.find_keys("*").length
    # -1 because collection 5 didn't have any document = one mapping for documents was added
    assert_equal(true, number_of_keys == final_number_of_keys-1)
  end

  def test_generate_sax_events
    file = File.absolute_path(FILE_PATH)
    name = File.basename(file)
    @doc_service.save_document(file)
    coll = XMLDBApi::RedCollection.new("1", "2", "coll")
    res = coll.create_resource("test_only", XMLDBApi::RedXmlResource::TYPE)
    handler = res.set_content_as_sax
    @doc_service.generate_sax_events(name, handler)
    res = @doc_service.get_resource(name)
    doc = res.get_content_as_dom
    result = doc.xpath("//a:product")
    assert_equal(true, result.length == 4)
    result = doc.xpath("//a:product/colorChoices").first
    assert_equal(true, "#{result}" == "<colorChoices attr:language=\"english\">navy black</colorChoices>")
  end

  def test_get_document_id
    assert_equal(true, @doc_service.get_document_id("test.xml") == "3")
    file = File.absolute_path(FILE_PATH)
    name = File.basename(file)
    @doc_service.save_document(file)
    # Iterator in db_init is "<iterator>", "9" so id must be 10
    assert_equal(true, @doc_service.get_document_id(name) == "10")
  end

  def test_get_all_documents_ids
    file = File.absolute_path(FILE_PATH)
    name = File.basename(file)
    @doc_service.save_document(file)
    ids = @doc_service.get_all_documents_ids
    # Remember, Hash in Redis does not guarantee order!
    assert_equal(true, ((ids[0] == "3" and ids[1] == "10") or (ids[0] == "10" and ids[1] == "3")))
    assert_equal(true, ids.length == 2)
  end

  def test_get_all_documents_names
    file = File.absolute_path(FILE_PATH)
    name = File.basename(file)
    @doc_service.save_document(file)
    names = @doc_service.get_all_documents_names
    # Remember, Hash in Redis does not guarantee order!
    assert_equal(true, ((names[0] == "test.xml" and names[1] == "catalog-ns.xml") or (names[0] == "catalog-ns.xml" and names[1] == "test.xml")))
    assert_equal(true, names.length == 2)
  end

  def test_delete_document
    file = File.absolute_path(FILE_PATH)
    name = File.basename(file)
    @doc_service.save_document(file)
    doc = @doc_service.find_document(name)
    @doc_service.delete_document(name)
    assert_raise Transformer::MappingException do
      doc = @doc_service.find_document(name)
    end
  end

  def test_rename_document
    file = File.absolute_path(FILE_PATH)
    name = File.basename(file)
    @doc_service.save_document(file)
    doc = @doc_service.find_document(name)
    @doc_service.rename_document(name, "new_name")
    assert_raise Transformer::MappingException do
      dc = @doc_service.find_document(name)
    end
    renamed_doc = @doc_service.find_document("new_name")
    assert_equal(true, "#{doc}" == "#{renamed_doc}")
  end

  def test_document_exist?
    assert_equal(true, @doc_service.document_exist?("test.xml") == true)
    assert_equal(true, @doc_service.document_exist?("testik.xml") == false)
    file = File.absolute_path(FILE_PATH)
    name = File.basename(file)
    @doc_service.save_document(file)
    assert_equal(true, @doc_service.document_exist?(name) == true)
    @doc_service.delete_document(name)
    assert_equal(true, @doc_service.document_exist?(name) == false)
  end
end