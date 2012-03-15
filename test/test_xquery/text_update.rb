require_relative "../../lib/red_xml_api/environment_manager"
require_relative "../../lib/xquery_module/xquery_controller"
require_relative "../../lib/xml/node"
require_relative "xquery_test_helper"
require "rubygems"
require "nokogiri"
require "test/unit"

#missing in other files
require_relative "../../lib/transformer/exceptions"
# require_relative "../../lib/transformer/document_service"


module XQuery
  class TestUpdate < Test::Unit::TestCase
    
    def test_update
      
      #test file
      XQueryTestHelper.create_test_file
      
      xquery_controller = XQuery::XQueryController.new(XQueryTestHelper::ENV_NAME, XQueryTestHelper::COLL_NAME)
      
      puts "QUERY: #{test_case.query}"
      new_results = xquery_controller.get_results(test_case.query)
      right_results = test_case.results
      
      assert_equal(right_results.length, new_results.length, "for query: #{test_case.query}, result count not the same")
      
      right_results.each_with_index { |right_result, index|
        new_result = new_results[index]
        if(new_result.kind_of?(Nokogiri::XML::Node))
          new_result = new_result.to_s
        end
        assert_equal(right_result, new_result, "for query: #{test_case.query}, results are not the same")
      }
      
      puts "test #{index+1}/#{TEST_CASES.length} ok"
      
      
      XQueryTestHelper.cleanup_test_file
      
    end
    
  end
end