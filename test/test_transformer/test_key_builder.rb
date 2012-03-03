require_relative "../db_init"
require_relative "../../lib/transformer/key_builder"
require_relative "../../lib/transformer/key_element_builder"
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
    puts "Calling all"
    call_all_instance_method_tests()
    puts "Done"
    @key_builder = Transformer::KeyBuilder.build_from_s(test_two)
    call_all_instance_method_tests()
    @key_builder = Transformer::KeyBuilder.build_from_s(test_three)
    #Return key_builder to it's original state so that we will not affect other tests alone
    @key_builder = Transformer::KeyBuilder.new("1", "2", "3")
  end
  
  def test_info()
    puts "KeyBuilder info je: #{@key_builder.info}"
    assert_equal(true, @key_builder.info == "1:2:3<info")
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
  