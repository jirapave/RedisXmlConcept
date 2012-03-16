require_relative "../../lib/red_xml_api/environment_manager"
require_relative "../../lib/xquery_module/xquery_controller"
require_relative "../../lib/xml/node"
require_relative "xquery_test_helper"
require "rubygems"
require "nokogiri"
require "test/unit"

#missing in other files
require_relative "../../lib/transformer/exceptions"


module XQuery
  class TestXQuery < Test::Unit::TestCase
    
    class TestCase
      
      attr_reader :query, :results
      
      def initialize(query, results)
        @query = query
        @results = results
      end
    end
    
    TEST_CASES = [
      #regular for, where, order by, return
      TestCase.new("for $prod in doc(  \"catalog.xml\"  )/catalog/product[position()<=3]  where $prod/@dept<=\"ACC\" order by $prod/name return $prod/name",
        ["<name language=\"en\">Deluxe Travel Bag</name>", "<name language=\"en\">Floppy Sun Hat</name>"]),
      #check where difference
      TestCase.new("for $prod in doc(  \"catalog.xml\"  )/catalog/product[position()<=3]  where $prod/@dept>=\"ACC\" order by $prod/name return $prod/name",
        ["<name language=\"en\">Deluxe Travel Bag</name>", '<name language="en">Fleece Pullover</name>', "<name language=\"en\">Floppy Sun Hat</name>"]),
      #check ascending order
      TestCase.new("for $prod in doc(  \"catalog.xml\"  )/catalog/product[position()<=3]  where $prod/@dept>=\"ACC\" order by $prod/name ascending return $prod/name",
        ["<name language=\"en\">Deluxe Travel Bag</name>", '<name language="en">Fleece Pullover</name>', "<name language=\"en\">Floppy Sun Hat</name>"]),
      #check descending order
      TestCase.new("for $prod in doc(  \"catalog.xml\"  )/catalog/product[position()<=3]  where $prod/@dept>=\"ACC\" order by $prod/name descending return $prod/name",
        ["<name language=\"en\">Floppy Sun Hat</name>", '<name language="en">Fleece Pullover</name>', "<name language=\"en\">Deluxe Travel Bag</name>"]),
      #check return element wrap
      TestCase.new("for $prod in doc(  \"catalog.xml\"  )/catalog/product[position()<=3]  where $prod/@dept<=\"ACC\" order by $prod/name return <elem>$prod/name</elem>",
        ["<elem><name language=\"en\">Deluxe Travel Bag</name></elem>", "<elem><name language=\"en\">Floppy Sun Hat</name></elem>"]),
      #check whitespaces and without order
      TestCase.new("for $prod in  doc(  \"catalog.xml\"  ) /  catalog/ product[position() <=3 ]  where $prod/@dept<=\"ACC\" return <elem>$prod/name</elem>",
        ["<elem><name language=\"en\">Floppy Sun Hat</name></elem>", "<elem><name language=\"en\">Deluxe Travel Bag</name></elem>"]),
      #check without where and order
      TestCase.new('for $prod in doc("catalog.xml")/catalog/product  return <elem>$prod/name</elem>',
        ['<elem><name language="en">Fleece Pullover</name></elem>', "<elem><name language=\"en\">Floppy Sun Hat</name></elem>", "<elem><name language=\"en\">Deluxe Travel Bag</name></elem>", '<elem><name language="en">Cotton Dress Shirt</name></elem>']),
      #check text
      TestCase.new('for $prod in doc("catalog.xml")/catalog/product[2]  return <elem>$prod/name/text()</elem>',
        ['<elem>Floppy Sun Hat</elem>']),
      #check let
      TestCase.new('for $prod in doc("catalog.xml")/catalog/product[2] let $name := $prod/name  return <elem>$name/text()</elem>',
        ['<elem>Floppy Sun Hat</elem>']),
      #let
      TestCase.new("for $prod in doc(  \"catalog.xml\"  )/catalog/product[position()<=3] let $name := $prod/name where $prod/@dept<=\"ACC\" order by $name return <elem>$name</elem>",
        ["<elem><name language=\"en\">Deluxe Travel Bag</name></elem>", "<elem><name language=\"en\">Floppy Sun Hat</name></elem>"]),
    ]
    
    
    
    def test_xquery
      
      XQueryTestHelper.create_test_file
      
      xquery_controller = XQuery::XQueryController.new(XQueryTestHelper::ENV_NAME, XQueryTestHelper::COLL_NAME)
      
      TEST_CASES.each_with_index { |test_case, index|
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
        
      }
      
      XQueryTestHelper.cleanup_test_file
      
    end
    
  end
end