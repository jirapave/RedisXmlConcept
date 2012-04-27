require "test/unit"
require_relative "xquery_test_helper"
if File.basename($0) == "#{File.basename(__FILE__)}"
  require_relative "../../lib/redxml.rb"
else
  require "redxml"
end


class TestTypeError < Test::Unit::TestCase

  QUERIES = [
    'doc("catalog.xml")/catalog/product/number[. eq 443]',
    'doc("catalog.xml")/catalog/product[number ge 443]',
    'doc("catalog.xml")/catalog/product/number["443" eq 443]',
    'doc("catalog.xml")/catalog/product[colorChoices][number = 784]/number',
    'doc("catalog.xml")/catalog/product/number[. = 443]',
    'doc("catalog.xml")/catalog/product[nocdata eq "1"]/@dept'
  ]  
  
  
  def test_type_errors
    
    xquery_test_helper = XQueryTestHelper.new
    xquery_test_helper.create_test_file
    
    xquery_controller = XQuery::XQueryController.new(XQueryTestHelper::ENV_NAME, XQueryTestHelper::COLL_NAME)
    
    QUERIES.each_with_index { |query, index|
      begin
        xquery_controller.get_results(query)
      rescue StandardError => e
        assert_equal(e.class, XQuery::TypeError, "for query: #{query}, raised exceptions are not the same")
        puts "test #{index+1}/#{QUERIES.length} ok"
        next
      end
      
      raise StandardError, "Test failed, query: '#{query}' should've raised TypeError"
      
    }
    
    xquery_test_helper.cleanup_test_file
    
  end
  
end