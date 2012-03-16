if File.basename($0) == "#{File.basename(__FILE__)}"
  require_relative "../../lib/redxml.rb"
else
  require "redxml"
end
require "test/unit"

class TestEnvironmentService < Test::Unit::TestCase
  
  def setup()
    DBInit.init_database
    @db_interface = BaseInterface::DBInterface.instance
    @env_service = Transformer::EnvironmentService.new()
    @coll_service = Transformer::CollectionService.new("1")
  end
  
  def test_create_environment()
    @env_service.create_environment("one")
    assert_nothing_raised do
      id = @env_service.get_environment_id("one") #Raise error if no id is retrieved
    end
    assert_equal(true, @env_service.environment_exist?("one") == true)
    @env_service.create_environment("two")
    assert_nothing_raised do
      id = @env_service.get_environment_id("two") #Raise error if no id is retrieved
    end
    assert_equal(true, @env_service.environment_exist?("two") == true)
    @env_service.create_environment("a26^dsa1*")
    assert_nothing_raised do
      id = @env_service.get_environment_id("a26^dsa1*") #Raise error if no id is retrieved
    end
    assert_equal(true, @env_service.environment_exist?("a26^dsa1*") == true)
  end
  
  def test_delete_environment()
    #This test fails when transaction in CollectionService>rename_collection is enaled AND this test
    #is run using run_selected_tests. When run alone, everyting works fine but when all tests are run
    #it fails. Main reason is probably some unexplainable behaviour of transaction method of DbInterface.transaction
    #ut im not sure.
    #This assert: assert_equal(true, colls.length == 5) #4
    #Fails because there are 6 collections, one named "nobody" which gets somehow created in rename_collection
    #in test_collection_service. What is strange, that before each test method, DBIinit.init_database should
    #be run, which deletes all keys and than recreates default database.
    aaa = @coll_service.get_all_child_collections_names
    assert_equal(true, @env_service.environment_exist?("esecond") == true)
    @env_service.delete_environment("esecond")
    assert_equal(true, @env_service.environment_exist?("esecond") == false)
    assert_equal(true, @env_service.environment_exist?("ethird") == true)
    @env_service.delete_environment("ethird")
    assert_equal(true, @env_service.environment_exist?("ethird") == false)
    coll_key = Transformer::KeyBuilder.collections_key("1")
    colls = @db_interface.find_value(coll_key)
    assert_equal(true, colls.length == 4) #4 collections in environment
    assert_equal(true, @env_service.environment_exist?("env") == true)
    @env_service.delete_environment("env")
    assert_equal(true, @env_service.environment_exist?("env") == false)
    colls = @db_interface.find_value(coll_key)
    assert_equal(true, colls == nil)
  end
  
  def test_delete_all_environments()
    env_key = Transformer::KeyBuilder.environments_key
    env = @env_service.get_all_environment_ids
    assert_equal(true, env.length == 4) #There are 4 environments
    coll_key = Transformer::KeyBuilder.collections_key("1")
    #We don' use CollectionService here, so we have to count <iterator> by hand
    colls = @db_interface.find_value(coll_key)
    #See comment in test_delete_environment
    assert_equal(true, colls.length == 4) 
    
    @env_service.delete_all_environments
    
    env = @env_service.get_all_environment_ids
    assert_equal(true, env.length == 0) #There are no environments
    colls = @db_interface.find_value(coll_key)
    #If this assertion fails, error is in CollectionService, because environment_manager
    #will call delete_all_collections for each environment
    assert_equal(true, colls == nil)
  end
  
  def test_get_environment_id()
    assert_equal(true, @env_service.get_environment_id("env") == "1")
    assert_equal(true, @env_service.get_environment_id("esecond") == "2")
    assert_equal(true, @env_service.get_environment_id("ethird") == "3")
    assert_equal(true, @env_service.get_environment_id("efourth") == "4")
    assert_raise Transformer::MappingException do
      @env_service.get_environment_id("something")
    end
  end
  
  def test_get_all_environment_ids()
    ids = @env_service.get_all_environment_ids
    assert_equal(true, ids.length == 4)
    assert_equal(true, ids.include?("1") == true)
    assert_equal(true, ids.include?("2") == true)
    assert_equal(true, ids.include?("3") == true)
    assert_equal(true, ids.include?("4") == true)
    assert_equal(true, ids.include?("5") == false)
    @env_service.delete_environment("esecond")
    ids = @env_service.get_all_environment_ids
    assert_equal(true, ids.length == 3)
    assert_equal(true, ids.include?("1") == true)
    assert_equal(true, ids.include?("2") == false)
    @env_service.create_environment("aaa")
    @env_service.create_environment("bbb")
    ids = @env_service.get_all_environment_ids
    assert_equal(true, ids.length == 5)
  end
  
  def test_get_all_environment_names()
    names = @env_service.get_all_environment_names
    assert_equal(true, names.length == 4)
    assert_equal(true, names.include?("env") == true)
    assert_equal(true, names.include?("esecond") == true)
    assert_equal(true, names.include?("ethird") == true)
    assert_equal(true, names.include?("efourth") == true)
    assert_equal(true, names.include?("blahblah") == false)
    @env_service.delete_environment("esecond")
    names = @env_service.get_all_environment_names
    assert_equal(true, names.length == 3)
    assert_equal(true, names.include?("env") == true)
    assert_equal(true, names.include?("esecond") == false)
    @env_service.create_environment("aaa")
    @env_service.create_environment("bbb")
    names = @env_service.get_all_environment_names
    assert_equal(true, names.length == 5)
  end
  
  def test_rename_environment()
    id = @env_service.get_environment_id("esecond")
    @env_service.rename_environment("esecond", "nobody")
    assert_equal(true, @env_service.get_environment_id("nobody") == id)
    assert_raise Transformer::MappingException do
     #esecond does not exist anymore, it was renamed
     @env_service.get_environment_id("esecond")
    end
    assert_raise Transformer::MappingException do
     @env_service.rename_environment("DoesntExist", "SomeName")
    end
  end
  
  def test_environment_exist?()
    assert_equal(true, @env_service.environment_exist?("env") == true)
    assert_equal(true, @env_service.environment_exist?("esecond") == true)
    assert_equal(true, @env_service.environment_exist?("nothing") == false)
    #@env_service.create_environment("nothing")
    #assert_equal(true, @env_service.environment_exist?("nothing") == true)
    #@env_service.delete_environment("nothing")
    #assert_equal(true, @env_service.environment_exist?("nothing") == false)
  end
  
end