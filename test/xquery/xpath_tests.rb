require_relative "../../lib/base_interface/db_interface"
require_relative "../../lib/transformer/document_service"
require_relative "../../lib/xquery/xquery_controller"
require_relative "../../lib/xml/node"
require "rubygems"
require "nokogiri"
require "test/unit"

module XQuery
  class XPathTests < Test::Unit::TestCase
    
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
      TestCase.new("doc(  \"catalog.xml\"  )/catalog/product/number[.=443]",
        ["<number>443</number>"]),
      TestCase.new("doc(  \"catalog.xml\"  )/catalog/product/number[. >= 563]",
        ["<number>563</number>", "<number>784</number>"]),
      TestCase.new("doc(  \"catalog.xml\"  )/catalog/product/number[. > 563]",
        ["<number>784</number>"]),
      TestCase.new("doc(  \"catalog.xml\"  )/catalog/product/number[. <= 563]",
        ["<number>557</number>", "<number>563</number>", "<number>443</number>"]),
      TestCase.new("doc(  \"catalog.xml\"  )/catalog/product/number[. < 563]",
        ["<number>557</number>", "<number>443</number>"]),
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
        ["<product dept=\"MEN\"><number>784</number><name language=\"en\">Cotton Dress Shirt</name><colorChoices>white gray</colorChoices><desc>Our<i>favorite</i>shirt!</desc></product>"]),
      TestCase.new("doc(\"catalog.xml\")//product[position() >= 4]",
        ["<product dept=\"MEN\"><number>784</number><name language=\"en\">Cotton Dress Shirt</name><colorChoices>white gray</colorChoices><desc>Our<i>favorite</i>shirt!</desc></product>"]),
      TestCase.new("doc(\"catalog.xml\")//product[position() > 3]",
        ["<product dept=\"MEN\"><number>784</number><name language=\"en\">Cotton Dress Shirt</name><colorChoices>white gray</colorChoices><desc>Our<i>favorite</i>shirt!</desc></product>"]),
      TestCase.new("doc(\"catalog.xml\")//product[3 < position()]",
        ["<product dept=\"MEN\"><number>784</number><name language=\"en\">Cotton Dress Shirt</name><colorChoices>white gray</colorChoices><desc>Our<i>favorite</i>shirt!</desc></product>"]),
      TestCase.new("doc(\"catalog.xml\")//product[last()]/name/text()",
        ["Cotton Dress Shirt"]),
      TestCase.new("doc(\"catalog.xml\")/catalog/product[name = \"Fleece Pullover\"]/number/text()",
        ["557"]),
    ] 
    
    def test_xpath
      
      db = BaseInterface::DBInterface.instance
      
      database = 1
      collection = 1
      file_name = "catalog.xml"
      
      document_service = Transformer::DocumentService.new()
      document_service.save_document(file_name, database, collection)
      
      xquery_controller = XQuery::XQueryController.new(database, collection)
      
      TEST_CASES.each { |test_case|
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
        
      }
      
    end
    
  end
end