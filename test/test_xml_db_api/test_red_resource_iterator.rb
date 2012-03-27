if File.basename($0) == "#{File.basename(__FILE__)}"
  require_relative "../../lib/redxml.rb"
elsif File.basename($0) == "generate_coverage.rb"
else
  require "redxml"
end
require "test/unit"

class TestRedResourceIterator < Test::Unit::TestCase
  def setup
  end

  def test_has_more_resources()
    set = XMLDBApi::RedResourceSet.new
    
    iterator = set.get_iterator
    assert_equal(true, iterator.has_more_resources? == false)
    
    doc = Nokogiri::XML("<root><book>First</book>")
    res = XMLDBApi::RedXmlResource.new("1", "1", "first", "1", doc)
    set.add_resource(res)
    
    doc = Nokogiri::XML("<root><book>Second</book>")
    res = XMLDBApi::RedXmlResource.new("1", "1", "second", "2", doc)
    set.add_resource(res)
    
    iterator = set.get_iterator
    assert_equal(true, iterator.has_more_resources? == true)
  end

  def test_next_resource()
    set = XMLDBApi::RedResourceSet.new
    
    iterator = set.get_iterator
    
    assert_raise XMLDBApi::Base::XMLDBException do
      res = iterator.next_resource
    end
    
    assert_equal(true, iterator.has_more_resources? == false)
    
    doc = Nokogiri::XML("<root><book>First</book>")
    res = XMLDBApi::RedXmlResource.new("1", "1", "first", "1", doc)
    set.add_resource(res)
    
    doc = Nokogiri::XML("<root><book>Second</book>")
    res = XMLDBApi::RedXmlResource.new("1", "1", "second", "2", doc)
    set.add_resource(res)
    
    iterator = set.get_iterator
    iter = 0
    while iterator.has_more_resources?
      res = iterator.next_resource
      if iter == 0
        assert_equal(true, res.get_document_id == "first")
      elsif iter == 1
        assert_equal(true, res.get_document_id == "second")
      end
      iter += 1
    end
  end

end