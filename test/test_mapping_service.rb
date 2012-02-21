require_relative "../lib/transformer/key_builder"
require_relative "../lib/transformer/mapping_service"
require_relative "db_init"
require "test/unit"

class TestMappingService < Test::Unit::TestCase
  
  def setup
    DBInit.init_database
    @key_builder = Transformer::KeyBuilder.create("env", "coll", "test.xml")
    @mapping_service = Transformer::MappingService.create(@key_builder)
  end
  
  def test_map_env()
    env_name = "env"
    env_id = Transformer::MappingService.map_env(env_name)
    assert_equal(true, env_id == "1")
    env_name = Transformer::MappingService.unmap_env(env_id)
    assert_equal(true, env_name == "env")
  end
  
end