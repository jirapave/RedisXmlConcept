require_relative "../../lib/xml_db_api/red_xml_resource"
require_relative "../db_init"
require "rubygems"
require "nokogiri"
require "test/unit"

class TestRedXmlResource < Test::Unit::TestCase
  def setup
    DBInit.init_database
  end

  def test_get_document_id()
    doc = Nokogiri::XML("<root><book>First</book></root>")
    res = XMLDBApi::RedXmlResource.new("1", "1", "first", "1", doc)
    assert_equal(true, res.get_document_id == "first")
    
    doc = Nokogiri::XML("<root><book>Second</book></root>")
    res = XMLDBApi::RedXmlResource.new("1", "1", "second", "1", doc)
    assert_equal(true, res.get_document_id == "second")
    
    res = XMLDBApi::RedXmlResource.new("1", "1", "third", "2", nil)
    assert_equal(true, res.get_document_id == "third")
  end

  def test_get_content_as_dom()
    doc = Nokogiri::XML("<root><book>First</book></root>")
    res = XMLDBApi::RedXmlResource.new("1", "1", "first", "1", doc)
    result = res.get_content_as_dom.xpath("//book").first
    assert_equal(true, "#{result}" == "<book>First</book>")
    
    doc = Nokogiri::XML("<root id=\"id1\" xmlns:a=\"http://aaaaa.com/a\"><a:book>Second</a:book></root>")
    res = XMLDBApi::RedXmlResource.new("1", "1", "second", "1", doc)
    result = res.get_content_as_dom.xpath("//a:book").first
    assert_equal(true, "#{result}" == "<a:book>Second</a:book>")
    
  end

  def test_set_content_as_dom()
    res = XMLDBApi::RedXmlResource.new("1", "1", "third", "2", nil)
    doc = Nokogiri::XML("<root><book>First</book></root>")
    res.set_content_as_dom(doc)
    assert_equal(true, res.empty? == false)
    assert_equal(true, res.get_content_as_dom.root.name == "root")
    
    res = XMLDBApi::RedXmlResource.new("1", "1", "third", "2", nil)
    doc = Nokogiri::XML("")
    res.set_content_as_dom(doc)
    assert_equal(true, res.empty? == false)
    assert_equal(true, res.get_content_as_dom.root == nil)
  end

  def test_get_content_as_sax()
    res_first = XMLDBApi::RedXmlResource.new("1", "1", "third", "2", nil)
    doc = Nokogiri::XML("<root><book>First</book></root>")
    res_first.set_content_as_dom(doc)
    
    res_second = XMLDBApi::RedXmlResource.new("2", "2", "fourth", "2", nil)
    handler = res_second.set_content_as_sax
    res_first.get_content_as_sax(handler)
    
    doc_first = res_first.get_content_as_dom
    doc_second = res_second.get_content_as_dom
    
    assert_equal(true, "#{doc_first}" == "#{doc_second}")
  end

  def test_set_content_as_sax()
    res_first = XMLDBApi::RedXmlResource.new("1", "1", "third", "2", nil)
    doc = Nokogiri::XML("<root xmlns:prefix=\"http://aaa.com/a\"><prefix:book>First</prefix:book></root>")
    res_first.set_content_as_dom(doc)
    
    res_second = XMLDBApi::RedXmlResource.new("2", "2", "fourth", "2", nil)
    handler = res_second.set_content_as_sax
    res_first.get_content_as_sax(handler)
    
    doc_first = res_first.get_content_as_dom
    doc_second = res_second.get_content_as_dom
    
    assert_equal(true, "#{doc_first}" == "#{doc_second}")
  end

  def test_get_parent_collection()
    res = XMLDBApi::RedXmlResource.new("1", "6", "third", "2", nil)
    coll = res.get_parent_collection
    
    assert_equal(true, coll.get_name == "child")
    
    res = XMLDBApi::RedXmlResource.new("1", "2", "third", "2", nil)
    coll = res.get_parent_collection
    assert_equal(true, coll.get_name == "coll")
  end

  def test_get_id()
    res = XMLDBApi::RedXmlResource.new("1", "6", "third", "2", nil)
    assert_equal(true, res.get_id == "third")
    
    res = XMLDBApi::RedXmlResource.new("1", "6", "something", "2", nil)
    assert_equal(true, res.get_id == "something")
  end

  def test_get_resource_type()
    res = XMLDBApi::RedXmlResource.new("1", "6", "third", "2", nil)
    assert_equal(true, res.get_resource_type == XMLDBApi::RedXmlResource::TYPE)
  end

  def test_get_content()
    doc = Nokogiri::XML("<root><book>First</book></root>")
    res = XMLDBApi::RedXmlResource.new("1", "1", "first", "1", doc)
    saved_doc = Nokogiri::XML(res.get_content)
    assert_equal(true, "#{saved_doc.xpath("//book").first}" == "<book>First</book>")
  end

  def test_set_content()
    res = XMLDBApi::RedXmlResource.new("1", "1", "first", "2", nil)
    res.set_content("<root><book>Second</book></root>")
    saved_doc = Nokogiri::XML(res.get_content)
    assert_equal(true, "#{saved_doc.xpath("//book").first}" == "<book>Second</book>")
  end

  def test_empty?
    res = XMLDBApi::RedXmlResource.new("1", "1", "first", "2", nil)
    assert_equal(true, res.empty? == true)
    res.set_content("<aaa></aaa>")
    assert_equal(true, res.empty? == false)
    res = XMLDBApi::RedXmlResource.new("1", "1", "first", "2", nil)
    assert_equal(true, res.empty? == true)
    doc = Nokogiri::XML("<another><book id=\"aabgd2\">Hello Dolly</book></another>")
    res.set_content_as_dom(doc)
    assert_equal(true, res.empty? == false)
    
    res_second = XMLDBApi::RedXmlResource.new("2", "2", "fourth", "2", nil)
    assert_equal(true, res_second.empty? == true)
    handler = res_second.set_content_as_sax
    res.get_content_as_sax(handler)
    assert_equal(true, res_second.empty? == false)
  end

end