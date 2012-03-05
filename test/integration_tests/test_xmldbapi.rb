require_relative "../db_init"
require_relative "../../lib/xml_db_api/database_manager"
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
end