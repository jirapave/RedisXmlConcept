if File.basename($0) == "#{File.basename(__FILE__)}"
  require_relative "../../lib/redxml.rb"
else
  require "redxml"
end
require "test/unit"

# We re using unit tests technology to create integration tests more easily
class TestXmlDbApi < Test::Unit::TestCase
  def setup
    @db = BaseInterface::DBInterface.instance
    #Delete whole content of database
    @db.delete_all_keys
  end
  
  # Test XML:DB API funcionalit only, proprietary functions are nos used here except
  # get_collection_management_service
  def test_manager_database_collection
    first_db = XMLDBApi::RedDatabase.new("first")
    assert_equal(true, first_db.accepts_uri?("xmldb:first://some/collections") == true)
    second_db = XMLDBApi::RedDatabase.new("second")
    service = first_db.get_collection_management_service
    service.create_collection("coll-1")
    service.create_collection("coll-2")
    XMLDBApi::DatabaseManager.register_database(first_db)
    
    coll = XMLDBApi::DatabaseManager.get_collection("xmldb:first://coll-1")
    service = coll.get_service("CollectionManagementService", "1.0")
    service.create_collection("coll-1-child")
    child_coll = coll.get_child_collection("coll-1-child")
    coll = child_coll.get_parent_collection
    assert_equal(true, coll.get_child_collection_count == 1)
    service = coll.get_service("CollectionManagementService", "1.0")
    service.remove_collection("coll-1-child")
    child_coll = coll.get_child_collection("coll-1-child")
    
    assert_equal(true, child_coll == nil)
    assert_equal(true, coll.get_child_collection_count == 0)
    assert_raise XMLDBApi::Base::XMLDBException do
      XMLDBApi::DatabaseManager.deregister_database(first_db)
      coll = XMLDBApi::DatabaseManager.get_collection("xmldb:first://coll-1")
    end
  end
  
  def test_resources()
    first_db = XMLDBApi::RedDatabase.new("first")
    assert_equal(true, first_db.accepts_uri?("xmldb:first://some/collections") == true)
    second_db = XMLDBApi::RedDatabase.new("second")
    service = first_db.get_collection_management_service
    coll = service.create_collection("coll-1")
    res = coll.create_resource("id1", XMLDBApi::RedXmlResource::TYPE)
    res.set_content("<root><book>Pad Hyperionu</book></root>")
    coll.store_resource(res)
    names = coll.list_resources
    assert_equal(true, names[0] == "id1")
    res = coll.get_resource("id1")
    
    res = coll.create_resource(nil, "XMLResource") #generates random id
    assert_raise XMLDBApi::Base::XMLDBException do
      coll.store_resource(res) #res is empty, cannot be stored
    end
    
    file = "#{__FILE__}/../books2.xml"
    handler = res.set_content_as_sax
    parser = Nokogiri::XML::SAX::Parser.new(handler)
    parser.parse(File.open(File.absolute_path(file)))
    
    document = res.get_content_as_dom
    id = res.get_document_id
    coll.store_resource(res)
    names = coll.list_resources
    assert_equal(true, names.length == 2)
    res = coll.get_resource(id)
    document = res.get_content_as_dom
    genre = document.xpath("//genre").first
    assert_equal(true, "#{genre}" == "<genre>Computer</genre>")
    
    coll.remove_resource(res)
    names = coll.list_resources
    assert_equal(true, (names.length == 1 and names[0] == "id1"))
    
    res = coll.create_resource("id20", XMLDBApi::RedXmlResource::TYPE)
    res.set_content("<root><book>Pad Hyperionu</book></root>")
    coll.store_resource(res)
    coll.remove_resource(res)
    res = coll.create_resource("id20", XMLDBApi::RedXmlResource::TYPE)
    res.set_content("<root><book>Pad Hyperionu</book></root>")
    coll.store_resource(res)
    res = coll.get_resource("id20")
    assert_equal(true, res.get_document_id == "id20")
    
    #SAX event generation
    res = coll.create_resource("id30", XMLDBApi::RedXmlResource::TYPE)
    res.set_content("<root><book>Next generation</book></root>")
    coll.store_resource(res)
    res = coll.create_resource("id31", XMLDBApi::RedXmlResource::TYPE)
    prev = coll.get_resource("id30")
    handler = res.set_content_as_sax
    prev.get_content_as_sax(handler)
    value1 = res.get_content_as_dom.xpath("//book").first.content
    value2 = prev.get_content_as_dom.xpath("//book").first.content
    assert_equal(true, value1 == value2)
  end
  
  def test_resource_sets()
    first_db = XMLDBApi::RedDatabase.new("first")
    service = first_db.get_collection_management_service
    coll = service.create_collection("coll-1")
    
    resource_set = XMLDBApi::RedResourceSet.new() #ResourceSet needs to part of certain database and collection
    
    res = coll.create_resource("id1", XMLDBApi::RedXmlResource::TYPE)
    res.set_content("<root><book id=\"aaa\">Pad Hyperionu</book></root>")
    coll.store_resource(res)
    res = coll.get_resource("id1")
    resource_set.add_resource(res)
    res = coll.create_resource("id2", XMLDBApi::RedXmlResource::TYPE)
    res.set_content("<root><book id=\"bbb\">Stret Kralu</book></root>")
    coll.store_resource(res)
    res = coll.get_resource("id2")
    resource_set.add_resource(res)
    res = coll.create_resource("id3", XMLDBApi::RedXmlResource::TYPE)
    res.set_content("<root><book id=\"ccc\">Nocni klub</book></root>")
    coll.store_resource(res)
    res = coll.get_resource("id3")
    resource_set.add_resource(res)
    
    all = resource_set.get_members_as_resource
    document = all.get_content_as_dom
    result = document.xpath("//resource")
    assert_equal(true, result.length == 3)
    result = document.xpath("//book[@id=\"ccc\"]")
    assert_equal(true, result.length == 1)
  end
end