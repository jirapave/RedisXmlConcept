require_relative "../db_init"
require_relative "../../lib/transformer/key_builder"
require_relative "../../lib/transformer/collection_service"
require "test/unit"

class TestCollectionService < Test::Unit::TestCase
  
  def setup()
    DBInit.init_database
    @db_interface = BaseInterface::DBInterface.instance
    @coll_service = Transformer::CollectionService.new("1")
  end
  
  def test_create_collection()
    @coll_service.create_collection("newest")
    assert_nothing_raised do
      id = @coll_service.get_collection_id("newest") #Raise error if no id is retrieved
    end
    assert_equal(true, @coll_service.collection_exist?("newest") == true)
    @coll_service.create_collection("another")
    assert_nothing_raised do
      id = @coll_service.get_collection_id("another") #Raise error if no id is retrieved
    end
    assert_equal(true, @coll_service.collection_exist?("another") == true)
    @coll_service.create_collection("a26^dsa1*")
    assert_nothing_raised do
      id = @coll_service.get_collection_id("a26^dsa1*") #Raise error if no id is retrieved
    end
    assert_equal(true, @coll_service.collection_exist?("a26^dsa1*") == true)
  end
  
  def test_delete_collection()
    assert_equal(true, @coll_service.collection_exist?("cthird") == true)
    @coll_service.delete_collection("cthird")
    assert_equal(true, @coll_service.collection_exist?("cthird") == false)
    assert_equal(true, @coll_service.collection_exist?("cfourth") == true)
    @coll_service.delete_collection("cfourth")
    assert_equal(true, @coll_service.collection_exist?("cfourth") == false)
    doc_key = Transformer::KeyBuilder.documents_key("1", "2") #env > coll where document is
    docs = @db_interface.find_value(doc_key)
    assert_equal(true, docs.length == 2) #1 document in collection + <iterator> field!!!
    assert_equal(true, @coll_service.collection_exist?("coll") == true)
    @coll_service.delete_collection("coll")
    assert_equal(true, @coll_service.collection_exist?("coll") == false)
    docs = @db_interface.find_value(doc_key)
    assert_equal(true, docs.length == 1) #0 documents in collection + <iterator>
    assert_equal(true, docs.include?("<iterator>") == true)
  end
  
  def test_delete_all_collections()
    env = @coll_service.get_all_collections_ids
    assert_equal(true, env.length == 4) #There are 4 Collections
    doc_key = Transformer::KeyBuilder.documents_key("1", "2")
    #We don' use CollectionService here, so we have to count <iterator> by hand
    docs = @db_interface.find_value(doc_key)
    assert_equal(true, docs.length == 2) #1 document in collection + iterator
    @coll_service.delete_all_collections
    coll = @coll_service.get_all_collections_ids
    assert_equal(true, coll.length == 0) #There are no collections
    docs = @db_interface.find_value(doc_key)
    #If this assertion fails, error is in CollectionService, because environment_manager
    #will call delete_all_collections for each environment
    assert_equal(true, docs.length == 1) #No documents in collection + <iterator>
    assert_equal(true, docs.include?("<iterator>") == true)
  end
  
  def test_get_collection_id()
    assert_equal(true, @coll_service.get_collection_id("coll") == "2")
    assert_equal(true, @coll_service.get_collection_id("cthird") == "3")
    assert_equal(true, @coll_service.get_collection_id("cfourth") == "4")
    assert_equal(true, @coll_service.get_collection_id("cfifth") == "5")
    assert_raise Transformer::MappingException do
      @coll_service.get_collection_id("something")
    end
  end
  
  def test_get_all_collections_ids()
    ids = @coll_service.get_all_collections_ids
    assert_equal(true, ids.length == 4)
    assert_equal(true, ids.include?("2") == true)
    assert_equal(true, ids.include?("3") == true)
    assert_equal(true, ids.include?("4") == true)
    assert_equal(true, ids.include?("5") == true)
    assert_equal(true, ids.include?("6") == false)
    @coll_service.delete_collection("cthird")
    ids = @coll_service.get_all_collections_ids
    assert_equal(true, ids.length == 3)
    assert_equal(true, ids.include?("2") == true)
    assert_equal(true, ids.include?("3") == false)
    @coll_service.create_collection("aaa")
    @coll_service.create_collection("bbb")
    ids = @coll_service.get_all_collections_ids
    assert_equal(true, ids.length == 5)
  end
  
  def test_get_all_collections_names()
    names = @coll_service.get_all_collections_names
    assert_equal(true, names.length == 4)
    assert_equal(true, names.include?("coll") == true)
    assert_equal(true, names.include?("cthird") == true)
    assert_equal(true, names.include?("cfourth") == true)
    assert_equal(true, names.include?("cfifth") == true)
    assert_equal(true, names.include?("blahblah") == false)
    @coll_service.delete_collection("cthird")
    names = @coll_service.get_all_collections_names
    assert_equal(true, names.length == 3)
    assert_equal(true, names.include?("coll") == true)
    assert_equal(true, names.include?("cthird") == false)
    @coll_service.create_collection("aaa")
    @coll_service.create_collection("bbb")
    names = @coll_service.get_all_collections_names
    assert_equal(true, names.length == 5)
  end
  
  def test_rename_collection()
    id = @coll_service.get_collection_id("cthird")
    @coll_service.rename_collection("cthird", "nobody")
    assert_equal(true, @coll_service.get_collection_id("nobody") == id)
    assert_raise Transformer::MappingException do
      #cthird does not exist anymore, it was renamed
     @coll_service.get_collection_id("cthird")
    end
    assert_raise Transformer::MappingException do
     @coll_service.rename_collection("DoesntExist", "SomeName")
    end
  end
  
  def test_collection_exist?()
    assert_equal(true, @coll_service.collection_exist?("coll") == true)
    assert_equal(true, @coll_service.collection_exist?("cthird") == true)
    assert_equal(true, @coll_service.collection_exist?("nothing") == false)
    @coll_service.create_collection("nothing")
    assert_equal(true, @coll_service.collection_exist?("nothing") == true)
    @coll_service.delete_collection("nothing")
    assert_equal(true, @coll_service.collection_exist?("nothing") == false)
  end
  
end