require_relative "../../lib/base_interface/db_interface"
require_relative "../../lib/transformer/document_service"
require_relative "../../lib/xquery/xquery_controller"
require_relative "../../lib/xml/node"
require "rubygems"
require "nokogiri"

module XQuery
  class XPathTests
    
    class TestCase
      
      attr_reader :query, :results
      
      def initialize(query, results)
        @query = query
        @results = results
      end
      
      def match(new_results)
        if(new_results.length == @results.length)
          new_results.each_with_index { |result, index|
            new_result = result
            if(result.kind_of?(XML::Node))
              new_result = result.to_stripped_s
            end
            if(new_result != @results[index])
              puts "query: #{query}, result expected: #{@results[index]}, result found: #{new_result}"
              return false
            end
          }
          return true
        end
        puts "query: #{query}, result count expected: #{@results.length}, result found: #{new_results.length}"
        return false
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
        ["Cotton Dress Shirt"])
      
    ] 
    
    def self.test
      
      db = BaseInterface::DBInterface.instance
      
      database = 1
      collection = 1
      file_name = "catalog.xml"
      
      document_service = Transformer::DocumentService.new()
      document_service.save_document(file_name, database, collection)
      
      xquery_controller = XQuery::XQueryController.new(database, collection)
      
      TEST_CASES.each { |test_case|
        results = xquery_controller.get_results(test_case.query)
        if(!test_case.match(results))
          fail StandardError, "TEST FAILED"
        end
      }
      
      puts "#{XPathTests} TEST PASSED"
      
    end
    
  end
end