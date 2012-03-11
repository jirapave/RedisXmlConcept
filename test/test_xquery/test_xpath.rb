require_relative "../../lib/red_xml_api/environment_manager"
require_relative "../../lib/xquery_module/xquery/xquery_controller"
require_relative "../../lib/xml/node"
require_relative "xquery_test_helper"
require "rubygems"
require "nokogiri"
require "test/unit"

#missing in other files
require_relative "../../lib/transformer/exceptions"
# require_relative "../../lib/transformer/document_service"


module XQuery
  class TestXPath < Test::Unit::TestCase
    
    class TestCase
      
      attr_reader :query, :results
      
      def initialize(query, results)
        @query = query
        @results = results
      end
    end
    
    TEST_CASES = [
      TestCase.new("doc(  \"catalog.xml\"  )/catalog/product/number[. = 443]",
        ["<number>443</number>"]),
      # TestCase.new("doc(  \"catalog.xml\"  )/catalog/product/number[. eq 443]",
        # []),#TODO this should be TypeError #TODO do another test class for errors TODO
      TestCase.new("doc(  \"catalog.xml\"  )/catalog/product/number[. eq '443']",
        ["<number>443</number>"]),
      TestCase.new("doc(  \"catalog.xml\"  )/catalog/product/number[.=443]",
        ["<number>443</number>"]),
      TestCase.new("doc(  \"catalog.xml\"  )/catalog/product/number[. >= 563]",
        ["<number>563</number>", "<number>784</number>"]),
      TestCase.new("doc(  \"catalog.xml\"  )/catalog/product/number[. ge '563']",
        ["<number>563</number>", "<number>784</number>"]),
      TestCase.new("doc(  \"catalog.xml\"  )/catalog/product/number[. > 563]",
        ["<number>784</number>"]),
      TestCase.new("doc(  \"catalog.xml\"  )/catalog/product/number[. <= 563]",
        ["<number>557<![CDATA[cdata cast<>]]></number>", "<number>563</number>", "<number>443</number>"]),
      TestCase.new("doc(  \"catalog.xml\"  )/catalog/product/number[. < 563]",
        ["<number>557<![CDATA[cdata cast<>]]></number>", "<number>443</number>"]),
      TestCase.new("doc(\"catalog.xml\")/catalog/product[number = 443]/@dept",
        ["ACC"]), 
      TestCase.new("doc(\"catalog.xml\")/catalog/product[number =443]/@dept",
        ["ACC"]),
      TestCase.new("doc(\"catalog.xml\")/catalog/product[number= 443]/@dept",
        ["ACC"]),
      TestCase.new("doc(\"catalog.xml\")/catalog/product[number=443]/@dept",
        ["ACC"]),
      TestCase.new("doc(\"catalog.xml\")//product[number=443]/@dept",
        ["ACC"]),
      TestCase.new("doc(\"catalog.xml\")/catalog/*[number=443]/@dept",
        ["ACC"]),
      TestCase.new("doc(\"catalog.xml\")/catalog/*[@dept = 'ACC']/@dept",
        ["ACC", "ACC"]),
      TestCase.new("doc(\"catalog.xml\")/catalog/*[@dept = \"ACC\"]/@dept",
        ["ACC", "ACC"]),
      TestCase.new("doc(\"catalog.xml\")//@dept",
        ["WMN", "ACC", "ACC", "MEN"]),
      TestCase.new("doc(\"catalog.xml\")//product[last()]",
        ["<product dept=\"MEN\"><number>784</number><name language=\"en\">Cotton Dress Shirt</name><colorChoices>white gray</colorChoices><desc>Our<i>favorite</i>shirt!<!-- Second commentary --></desc></product>"]),
      TestCase.new("doc(\"catalog.xml\")//product[position() >= 4]",
        ["<product dept=\"MEN\"><number>784</number><name language=\"en\">Cotton Dress Shirt</name><colorChoices>white gray</colorChoices><desc>Our<i>favorite</i>shirt!<!-- Second commentary --></desc></product>"]),
      TestCase.new("doc(\"catalog.xml\")//product[position() > 3]",
        ["<product dept=\"MEN\"><number>784</number><name language=\"en\">Cotton Dress Shirt</name><colorChoices>white gray</colorChoices><desc>Our<i>favorite</i>shirt!<!-- Second commentary --></desc></product>"]),
      TestCase.new("doc(\"catalog.xml\")//product[3 < position()]",
        ["<product dept=\"MEN\"><number>784</number><name language=\"en\">Cotton Dress Shirt</name><colorChoices>white gray</colorChoices><desc>Our<i>favorite</i>shirt!<!-- Second commentary --></desc></product>"]),
      TestCase.new("doc(\"catalog.xml\")//product[last()]/name/text()",
        ["Cotton Dress Shirt"]),
      TestCase.new("doc(\"catalog.xml\")/catalog/product[name = \"Fleece Pullover\"]/number/text()",
        ["557cdata cast<>"]),
    ]
    
    
    def test_xpath
      
      XQueryTestHelper.create_test_file
      
      xquery_controller = XQuery::XQueryController.new(XQueryTestHelper::ENV_NAME, XQueryTestHelper::COLL_NAME)
      
      TEST_CASES.each_with_index { |test_case, index|
        puts "QUERY: #{test_case.query}"
        new_results = xquery_controller.get_results(test_case.query)
        right_results = test_case.results
        
        assert_equal(right_results.length, new_results.length, "for query: #{test_case.query}, result count not the same")
        
        right_results.each_with_index { |right_result, index|
          new_result = new_results[index]
          if(new_result.kind_of?(XML::Node))
            new_result = new_result.to_stripped_s
          end
          assert_equal(right_result, new_result, "for query: #{test_case.query}, results are not the same")
        }
        
        puts "test #{index+1}/#{TEST_CASES.length} ok"
        
      }
      
      XQueryTestHelper.cleanup_test_file
      
    end
    
  end
end