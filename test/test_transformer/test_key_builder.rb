if File.basename($0) == "#{File.basename(__FILE__)}"
  require_relative "../../lib/redxml.rb"
else
  require "redxml"
end
require "test/unit"

class TestKeyBuilder < Test::Unit::TestCase
  
  def setup()
    @key_builder = Transformer::KeyBuilder.new("1", "2", "3")
  end
  
  def test_evironments_key()
    assert_equal(true, Transformer::KeyBuilder.environments_key == "environments")
  end
  
  def test_colletions_key()
    assert_equal(true, Transformer::KeyBuilder.collections_key("1") == "1:collections")
  end
  
  def test_child_colletions_key()
    assert_equal(true, Transformer::KeyBuilder.child_collections_key("1", "2") == "1:2:collections")
  end
  
  def test_documents_key()
    assert_equal(true, Transformer::KeyBuilder.documents_key("1", "2") == "1:2:documents")
  end
  
  def test_build_from_s()
    test_one = "1:2:3<info"
    test_two = "1:2:3"
    test_three = "1:2:3<nonsense"
    @key_builder = Transformer::KeyBuilder.build_from_s(test_one)
    call_all_instance_method_tests()
    @key_builder = Transformer::KeyBuilder.build_from_s(test_two)
    call_all_instance_method_tests()
    @key_builder = Transformer::KeyBuilder.build_from_s(test_three)
    #Return key_builder to it's original state so that we will not affect other tests alone
    @key_builder = Transformer::KeyBuilder.new("1", "2", "3")
  end
  
  def test_collection_info()
    @key_builder = Transformer::KeyBuilder.new("1", "2", "3")
    assert_equal(true, @key_builder.collection_info == "1:2<info")
    assert_equal(true, Transformer::KeyBuilder.collection_info("a3c", "555") == "a3c:555<info")
  end
  
  def test_environment_info()
    @key_builder = Transformer::KeyBuilder.new("1", "2", "3")
    assert_equal(true, @key_builder.environment_info == "1<info")
    assert_equal(true, Transformer::KeyBuilder.environment_info("a3c") == "a3c<info")
  end
  
  def test_info()
    assert_equal(true, @key_builder.info == "1:2:3<info")
  end
  
  def test_env_iterator_key
    assert_equal(true, Transformer::KeyBuilder.env_iterator_key == "info")
  end
  
  def test_elem_mapping_key()
    assert_equal(true, @key_builder.elem_mapping_key == "1:2:3<emapping")
  end
  
  def test_attr_mapping_key()
    assert_equal(true, @key_builder.attr_mapping_key == "1:2:3<amapping")
  end
  
  def test_content_key()
    assert_equal(true, @key_builder.content_key == "1:2:3<content")
  end
  
  def test_root()
    element_builder = @key_builder.root("1")
    assert_equal(true, (element_builder.instance_of?(Transformer::KeyElementBuilder) and element_builder.root_key == "1"))
    element_builder = @key_builder.root(1)
    assert_equal(true, (element_builder.instance_of?(Transformer::KeyElementBuilder) and element_builder.root_key == "1"))
  end
  
  def test_to_s()
    result = "#{@key_builder}"
    assert_equal(true, result == "1:2:3")
  end
  
  private
  def call_all_instance_method_tests()
    test_info
    test_elem_mapping_key
    test_attr_mapping_key
    test_content_key
    test_root
    test_to_s
  end
end
  