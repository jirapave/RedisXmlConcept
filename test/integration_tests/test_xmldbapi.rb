require_relative "../db_init"
require_relative "../../lib/xml_db_api/database_manager"
require_relative "../../lib/xml_db_api/red_xml_resource"
require_relative "../../lib/xml_db_api/base/xmldb_exception"
require_relative "../../lib/transformer/collection_service"
require_relative "../../lib/xml_db_api/red_collection_management_service"
require_relative "../../lib/base_interface/db_interface"
require "test/unit"

# We re using unit tests technology to create integration tests more easily
class TestXmlbApi < Test::Unit::TestCase
  def setup
    db = BaseInterface::DBInterface.instance
    #Delete whole content of database
    keys = db.find_keys("*")
    db.delete_keys keys unless keys.empty?
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
    service = coll.get_service("RedCollectionManagementService", "1.0")
    service.create_collection("coll-1-child")
    child_coll = coll.get_child_collection("coll-1-child")
    coll = child_coll.get_parent_collection
    assert_equal(true, coll.get_child_collection_count == 1)
    service = coll.get_service("RedCollectionManagementService", "1.0")
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
    id = res.get_document_id
    assert_raise XMLDBApi::Base::XMLDBException do
      coll.store_resource(res) #res is empty, cannot be stored
    end
    
    file = "../../bin/books2.xml"
    handler = res.set_content_as_sax
    parser = Nokogiri::XML::SAX::Parser.new(handler)
    parser.parse(File.open(File.absolute_path(file)))
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
  end
end