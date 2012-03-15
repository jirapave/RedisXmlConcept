require "test/unit"
require_relative "../../lib/xml_db_api/red_xml_resource"
require_relative "../../lib/xml_db_api/red_resource_set"
require_relative "../../lib/xml_db_api/red_resource_iterator"
require_relative "../../lib/xml_db_api/base/resource_iterator"

require "rubygems"
require "nokogiri"

class TestRedResourceSet < Test::Unit::TestCase
  def setup
  end

  def test_get_resource()
    set = XMLDBApi::RedResourceSet.new
    
    doc = Nokogiri::XML("<root><book>First</book>")
    res = XMLDBApi::RedXmlResource.new("1", "1", "first", "1", doc)
    set.add_resource(res)
    
    doc = Nokogiri::XML("<root><book>Second</book>")
    res = XMLDBApi::RedXmlResource.new("1", "1", "second", "2", doc)
    set.add_resource(res)
    
    assert_equal(true, set.get_resource(0).get_document_id == "first")
    assert_equal(true, set.get_resource(1).get_document_id == "second")
    
    assert_raise XMLDBApi::Base::XMLDBException do
      set.get_resource(3)
    end
  end

  def test_add_resource()
    set = XMLDBApi::RedResourceSet.new
    
    doc = Nokogiri::XML("<root><book>First</book>")
    res = XMLDBApi::RedXmlResource.new("1", "1", "first", "1", doc)
    set.add_resource(res)
    
    assert_equal(true, set.get_size == 1)
    
    doc = Nokogiri::XML("<root><book>Second</book>")
    res = XMLDBApi::RedXmlResource.new("1", "1", "second", "2", doc)
    set.add_resource(res)
    
    assert_equal(true, set.get_size == 2)
  end

  def test_remove_resource()
    set = XMLDBApi::RedResourceSet.new
    
    doc = Nokogiri::XML("<root><book>First</book>")
    res = XMLDBApi::RedXmlResource.new("1", "1", "first", "1", doc)
    set.add_resource(res)
    
    assert_equal(true, set.get_size == 1)
    
    set.remove_resource(0)
    
    assert_equal(true, set.get_size == 0)
    
    doc = Nokogiri::XML("<root><book>Second</book>")
    res = XMLDBApi::RedXmlResource.new("1", "1", "first", "1", doc)
    set.add_resource(res)
    
    doc = Nokogiri::XML("<root><book>Second</book>")
    res = XMLDBApi::RedXmlResource.new("1", "1", "second", "2", doc)
    set.add_resource(res)
    
    set.remove_resource(1)
    
    assert_equal(true, set.get_resource(0).get_document_id == "first")
    
    assert_equal(true, set.get_size == 1)
  end

  def test_get_iterator()
    set = XMLDBApi::RedResourceSet.new
    
    doc = Nokogiri::XML("<root><book>First</book>")
    res = XMLDBApi::RedXmlResource.new("1", "1", "first", "1", doc)
    set.add_resource(res)
    
    iterator = set.get_iterator
    
    assert_equal(true, iterator.kind_of?(XMLDBApi::Base::ResourceIterator))
  end

  def test_get_members_as_resource()
    set = XMLDBApi::RedResourceSet.new
    
    doc = Nokogiri::XML("<root><book>First</book>")
    res = XMLDBApi::RedXmlResource.new("1", "1", "first", "1", doc)
    set.add_resource(res)
    
    doc = Nokogiri::XML("<root><book>Second</book>")
    res = XMLDBApi::RedXmlResource.new("1", "1", "second", "2", doc)
    set.add_resource(res)
    
    result = set.get_members_as_resource.get_content_as_dom
    query_result = result.xpath("//resource")
    assert_equal(true, query_result.length == 2)
    query_result = result.xpath("//resources")
    assert_equal(true, query_result.length == 1)
    query_result = result.xpath("//book")
    assert_equal(true, query_result.length == 2)
    
  end

  def test_get_size()
    set = XMLDBApi::RedResourceSet.new
    
    assert_equal(true, set.get_size == 0)
    
    doc = Nokogiri::XML("<root><book>First</book>")
    res = XMLDBApi::RedXmlResource.new("1", "1", "first", "1", doc)
    set.add_resource(res)
    
    assert_equal(true, set.get_size == 1)
    
    doc = Nokogiri::XML("<root><book>Second</book>")
    res = XMLDBApi::RedXmlResource.new("1", "1", "second", "2", doc)
    set.add_resource(res)
    
    assert_equal(true, set.get_size == 2)
    
    set.remove_resource(0)
    set.remove_resource(0)
    set.remove_resource(0)
    
    assert_equal(true, set.get_size == 0)
    
  end

  def test_clear()
    set = XMLDBApi::RedResourceSet.new
    
    assert_equal(true, set.get_size == 0)
    set.clear
    assert_equal(true, set.get_size == 0)
    
    doc = Nokogiri::XML("<root><book>First</book>")
    res = XMLDBApi::RedXmlResource.new("1", "1", "first", "1", doc)
    set.add_resource(res)
    
    assert_equal(true, set.get_size == 1)
    set.clear
    assert_equal(true, set.get_size == 0)
  end

end