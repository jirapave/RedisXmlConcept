require_relative "../db_init"
require_relative "../../lib/xml_db_api/database_manager"
require_relative "../../lib/xml_db_api/red_xml_resource"
require_relative "../../lib/xml_db_api/red_resource_set"
require_relative "../../lib/xml_db_api/base/xmldb_exception"
require_relative "../../lib/transformer/collection_service"
require_relative "../../lib/xml_db_api/red_collection_management_service"
require_relative "../../lib/base_interface/db_interface"
require "test/unit"

# This test is for internal purposes only. It is used to simulate very rare and well hidden bug which i am
# unable to explain, if we set overwrite to false when saving descendant keys in xml_transformer than one assertion
# fails in test_resources but ONLY if the test_resource_sets is active, if test_resource_sets will not be
# launched, than test_resources will work as expected.
class TestHelper < Test::Unit::TestCase
  def setup
    @db = BaseInterface::DBInterface.instance
    #Delete whole content of database
    @db.delete_all_keys
  end
  
  def test_resources()
    first_db = XMLDBApi::RedDatabase.new("first")
    service = first_db.get_collection_management_service
    coll = service.create_collection("coll-1")
    
    res = coll.create_resource(nil, "XMLResource") #generates random id
    
    file = "../../bin/catalog.xml"
    handler = res.set_content_as_sax
    parser = Nokogiri::XML::SAX::Parser.new(handler)
    parser.parse(File.open(File.absolute_path(file)))
    
    document = res.get_content_as_dom
    id = res.get_document_id
    coll.store_resource(res)
    names = coll.list_resources
    res = coll.get_resource(id)
    document = res.get_content_as_dom
    genre = document.xpath("//name").first
    assert_equal(true, "#{genre}" == "<name language=\"en\">Fleece Pullover</name>")
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
  end
end