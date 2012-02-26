require_relative "../db_init"
require_relative "../../lib/transformer/key_builder"
require_relative "../../lib/transformer/mapping_service"
require "test/unit"

class TestMappingService < Test::Unit::TestCase
  
  def setup
    DBInit.init_database
  end
  
  #Test for api of mapping_service class, DBInit creates following structure
  #environment {"env" => 1}, collection {"coll" => 2} and file {"test.xml" => 3}
  #<catalog encoding="UTF-8" version="1.0" standalone="YES">
  #  <product dept="WMN" language="cz">
  #    <number>557</number>
  #    <name language="en">Fleece Pullover</name>
  #    <colorChoices>navy black</colorChoices>
  #  </product>
  #</catalog>
  
  ENV_ID = "1"
  COLL_ID = "2"
  DOC_ID = "3"
  
  def test_map_env()
    env_name = "env"
    env_id = Transformer::MappingService.map_env(env_name)
    assert_equal(true, env_id == "1")
  end
  
  def test_unmap_env()
    env_id = "1"
    env_name = Transformer::MappingService.unmap_env(env_id)
    assert_equal(true, env_name == "env")
  end
  
  def test_map_coll()
    env_id = "1"
    coll_id = Transformer::MappingService.map_coll(env_id, "coll")
    assert_equal(true, coll_id == "2")
  end
  
  def test_unmap_coll()
    coll_id = "2"
    coll_name = Transformer::MappingService.unmap_coll("1", coll_id)
    assert_equal(true, coll_name == "coll")
  end
  
  def test_map_doc()
    env_id = "1"
    coll_id = "2"
    doc_name = "test.xml"
    doc_id = Transformer::MappingService.map_doc(env_id, coll_id, doc_name)
    assert_equal(true, doc_id == "3")
  end
  
  def test_unmap_coll()
    env_id = "1"
    coll_id = "2"
    doc_name = Transformer::MappingService.unmap_doc(env_id, coll_id, "3")
    assert_equal(true, doc_name == "test.xml")
  end
  
  def test_map_env_coll()
    env_name = "env"
    coll_name = "coll"
    mapping = Transformer::MappingService.map_env_coll(env_name, coll_name)
    env_id = mapping[Transformer::MappingService::ENV_KEY]
    coll_id = mapping[Transformer::MappingService::COLL_KEY]
    assert_equal(true, (env_id == "1" and coll_id == "2"))
  end
  
  def test_unmap_env_coll()
    env_id = "1"
    coll_id = "2"
    mapping = Transformer::MappingService.unmap_env_coll(env_id, coll_id)
    env_name = mapping[Transformer::MappingService::ENV_KEY]
    coll_name = mapping[Transformer::MappingService::COLL_KEY]
    assert_equal(true, (env_name == "env" and coll_name == "coll"))
  end
  
  def test_map_env_coll_doc()
    env_name = "env"
    coll_name = "coll"
    doc_name = "test.xml"
    mapping = Transformer::MappingService.map_env_coll_doc(env_name, coll_name, doc_name)
    env_id = mapping[Transformer::MappingService::ENV_KEY]
    coll_id = mapping[Transformer::MappingService::COLL_KEY]
    doc_id = mapping[Transformer::MappingService::DOC_KEY]
    assert_equal(true, (env_id == "1" and coll_id == "2" and doc_id == "3"))
  end
  
  def test_unmap_env_coll_doc()
    env_id = "1"
    coll_id = "2"
    doc_id = "3"
    mapping = Transformer::MappingService.unmap_env_coll_doc(env_id, coll_id, doc_id)
    env_name = mapping[Transformer::MappingService::ENV_KEY]
    coll_name = mapping[Transformer::MappingService::COLL_KEY]
    doc_name = mapping[Transformer::MappingService::DOC_KEY]
    assert_equal(true, (env_name == "env" and coll_name == "coll" and doc_name == "test.xml"))
  end
  
  def test_map_elem_name()
    key_builder = Transformer::KeyBuilder.new(ENV_ID, COLL_ID, DOC_ID)
    mapping_service = Transformer::MappingService.new(key_builder)
    catalog_id = mapping_service.map_elem_name("catalog")
    product_id = mapping_service.map_elem_name("product")
    number_id = mapping_service.map_elem_name("number")
    name_id = mapping_service.map_elem_name("name")
    colorChoices_id = mapping_service.map_elem_name("colorChoices")
    assert_equal(true, (catalog_id == "1" and product_id == "2" and number_id == "3" and name_id == "4" and colorChoices_id == "5"))
  end
  
  def test_unmap_elem_name()
    key_builder = Transformer::KeyBuilder.new(ENV_ID, COLL_ID, DOC_ID)
    mapping_service = Transformer::MappingService.new(key_builder)
    catalog_name = mapping_service.unmap_elem_name("1")
    product_name = mapping_service.unmap_elem_name("2")
    number_name = mapping_service.unmap_elem_name("3")
    name_name = mapping_service.unmap_elem_name("4")
    colorChoices_name = mapping_service.unmap_elem_name("5")
    assert_equal(true, (catalog_name == "catalog" and product_name == "product" and number_name == "number" and name_name == "name" and colorChoices_name == "colorChoices"))
  end
  
  def test_map_attr_name()
    key_builder = Transformer::KeyBuilder.new(ENV_ID, COLL_ID, DOC_ID)
    mapping_service = Transformer::MappingService.new(key_builder)
    dept_id = mapping_service.map_attr_name("dept")
    language_id = mapping_service.map_attr_name("language")
    assert_equal(true, (dept_id == "1" and language_id == "2"))
  end
  
  def test_unmap_attr_name()
    key_builder = Transformer::KeyBuilder.new(ENV_ID, COLL_ID, DOC_ID)
    mapping_service = Transformer::MappingService.new(key_builder)
    dept_name = mapping_service.unmap_attr_name("1")
    language_name = mapping_service.unmap_attr_name("2")
    assert_equal(true, (dept_name == "dept" and language_name == "language"))
  end
  
  def test_create_elem_mapping()
    key_builder = Transformer::KeyBuilder.new(ENV_ID, COLL_ID, DOC_ID)
    mapping_service = Transformer::MappingService.new(key_builder)
    val = BaseInterface::DBInterface.instance.get_hash_value(key_builder.elem_mapping_key, "<iterator>")
    elem_id = mapping_service.create_elem_mapping("escaping")
    val = BaseInterface::DBInterface.instance.get_hash_value(key_builder.elem_mapping_key, "<iterator>")
    assert_equal(true, elem_id.instance_of?(String))
    elem_name = mapping_service.unmap_elem_name(elem_id)
    assert_equal(true, elem_name == "escaping")
  end
  
  def test_create_attr_mapping()
    key_builder = Transformer::KeyBuilder.new(ENV_ID, COLL_ID, DOC_ID)
    mapping_service = Transformer::MappingService.new(key_builder)
    attr_id = mapping_service.create_attr_mapping("running")
    assert_equal(true, attr_id.instance_of?(String))
    attr_name = mapping_service.unmap_attr_name(attr_id)
    assert_equal(true, attr_name == "running")
  end
  
end