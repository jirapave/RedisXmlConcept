require_relative "../../lib/red_xml_api/environment_manager"
require_relative "../../lib/xquery_module/update_controller"
require_relative "../../lib/xquery_module/xquery_controller"
require_relative "../../lib/xml/node"
require_relative "xquery_test_helper"
require "rubygems"
require "nokogiri"
require "test/unit"

#missing in other files
require_relative "../../lib/transformer/exceptions"


module XQuery
  class TestUpdate < Test::Unit::TestCase
    
    class TestCase
      
      attr_reader :checking_query, :before_results, :update_query, :after_results
      
      def initialize(checking_query, before_results, update_query, after_results)
        @checking_query = checking_query
        @before_results = before_results
        @update_query = update_query
        @after_results = after_results
      end
    end
    
    TEST_CASES = [
      TestCase.new(
        'doc("catalog.xml")/catalog/product[3]/name/text()',
        [ "Deluxe Travel Bag" ],
        'delete node doc("catalog.xml")/catalog/product[3]',
        [ "Cotton Dress Shirt" ]
      )
    ]
    
    def test_update
      
      #test file
      XQueryTestHelper.create_test_file
      
      xquery_controller = XQuery::XQueryController.new(XQueryTestHelper::ENV_NAME, XQueryTestHelper::COLL_NAME)
      update_controller = XQuery::UpdateController.new(XQueryTestHelper::ENV_NAME, XQueryTestHelper::COLL_NAME)
      
      TEST_CASES.each { |test_case|
        puts "CHECKING QUERY: #{test_case.checking_query}"
        puts "BEFORE RESULTS: #{test_case.before_results}"
        puts "UPDATE QUERY: #{test_case.update_query}"
        puts "AFTER RESULTS: #{test_case.after_results}"

        #check before        
        before_results = xquery_controller.get_results(test_case.checking_query)
        assert_equal(test_case.before_results.length, before_results.length, "for checking query (BEFORE): #{test_case.checking_query}, result count not the same")
        test_case.before_results.each_with_index { |result, index|
          before = before_results[index]
          if(before.kind_of?(Nokogiri::XML::Node))
            before = before.to_s
          end
          assert_equal(result, before, "for checking query (BEFORE): #{test_case.checking_query}, results are not the same")
        }
        
        
        #perform update
        update_controller.perform(test_case.update_query)
        
        #check results by checking query and after results
        after_results = xquery_controller.get_results(test_case.checking_query)
        assert_equal(test_case.after_results.length, after_results.length, "for checking query (AFTER): #{test_case.checking_query}, result count not the same")
        test_case.after_results.each_with_index { |result, index|
          after = after_results[index]
          if(after.kind_of?(Nokogiri::XML::Node))
            after = after.to_s
          end
          assert_equal(result, after, "for checking query (AFTER): #{test_case.checking_query}, results are not the same")
        }
        
        puts "test #{index+1}/#{TEST_CASES.length} ok"
        
        
      }
      
      
      XQueryTestHelper.cleanup_test_file
      
    end
    
  end
end