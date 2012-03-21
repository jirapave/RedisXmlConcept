# require_relative "../../lib/red_xml_api/environment_manager"
# require_relative "../../lib/xquery_module/update_controller"
# require_relative "../../lib/xquery_module/xquery_controller"
# require_relative "../../lib/xml/node"
require_relative "xquery_test_helper"
# require "rubygems"
# require "nokogiri"
if File.basename($0) == "#{File.basename(__FILE__)}"
  require_relative "../../lib/redxml.rb"
else
  require "redxml"
end
require "test/unit"

#missing in other files
# require_relative "../../lib/transformer/exceptions"


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
      ),
      TestCase.new(
        'doc("catalog.xml")/catalog/product[2]/name/text()',
        [ "Floppy Sun Hat" ],
        'for $prod in doc("catalog.xml")/catalog/product where $prod/number = 563 return delete node $prod',
        # [ "Cotton Dress Shirt" ]
        [ "Deluxe Travel Bag" ]
      )
    ]
    
    def test_update
      
      
      #test file
      xquery_test_helper = XQueryTestHelper.new        
      
      
      
      xquery_controller = XQuery::XQueryController.new(XQueryTestHelper::ENV_NAME, XQueryTestHelper::COLL_NAME)
      
      
      TEST_CASES.each_with_index { |test_case, index|
        
        xquery_test_helper.create_test_file
        
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
        xquery_controller.get_results(test_case.update_query)
        
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
        
        
        xquery_test_helper.cleanup_test_file
        
      }
      
      
      
      
    end
    
  end
end