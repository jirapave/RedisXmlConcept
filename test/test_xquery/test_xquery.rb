require_relative "xquery_test_helper"
if File.basename($0) == "#{File.basename(__FILE__)}"
  require_relative "../../lib/redxml.rb"
else
  require "redxml"
end
require "test/unit"


class TestXQuery < Test::Unit::TestCase
  
  class TestCase
    
    attr_reader :query, :results
    
    def initialize(query, results)
      @query = query
      @results = results
    end
  end
  
  TEST_CASES = [
    #more for
    TestCase.new('for $prod in doc("catalog.xml")/catalog/product
                  for $name in doc("catalog.xml")/catalog/product/name
                  return $name',
      ['<name language="en">Fleece Pullover</name>', '<name language="en">Floppy Sun Hat</name>', '<name language="en">Deluxe Travel Bag</name>', '<name language="en">Cotton Dress Shirt</name>',
       '<name language="en">Fleece Pullover</name>', '<name language="en">Floppy Sun Hat</name>', '<name language="en">Deluxe Travel Bag</name>', '<name language="en">Cotton Dress Shirt</name>',
       '<name language="en">Fleece Pullover</name>', '<name language="en">Floppy Sun Hat</name>', '<name language="en">Deluxe Travel Bag</name>', '<name language="en">Cotton Dress Shirt</name>',
       '<name language="en">Fleece Pullover</name>', '<name language="en">Floppy Sun Hat</name>', '<name language="en">Deluxe Travel Bag</name>', '<name language="en">Cotton Dress Shirt</name>',]),
    #second let instead of that for
    TestCase.new('for $prod in doc("catalog.xml")/catalog/product
                  let $name := doc("catalog.xml")/catalog/product/name
                  return $name',
      ['<name language="en">Fleece Pullover</name><name language="en">Floppy Sun Hat</name><name language="en">Deluxe Travel Bag</name><name language="en">Cotton Dress Shirt</name>',
       '<name language="en">Fleece Pullover</name><name language="en">Floppy Sun Hat</name><name language="en">Deluxe Travel Bag</name><name language="en">Cotton Dress Shirt</name>',
       '<name language="en">Fleece Pullover</name><name language="en">Floppy Sun Hat</name><name language="en">Deluxe Travel Bag</name><name language="en">Cotton Dress Shirt</name>',
       '<name language="en">Fleece Pullover</name><name language="en">Floppy Sun Hat</name><name language="en">Deluxe Travel Bag</name><name language="en">Cotton Dress Shirt</name>']),
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
      ["<elem>$prod/name</elem>", "<elem>$prod/name</elem>"]),
    TestCase.new("for $prod in doc(  \"catalog.xml\"  )/catalog/product[position()<=3]  where $prod/@dept<=\"ACC\" order by $prod/name return <elem>{$prod/name}</elem>",
      ["<elem><name language=\"en\">Deluxe Travel Bag</name></elem>", "<elem><name language=\"en\">Floppy Sun Hat</name></elem>"]),
    #check whitespaces and without order
    TestCase.new("for $prod in  doc(  \"catalog.xml\"  ) /  catalog/ product[position() <=3 ]  where $prod/@dept<=\"ACC\" return <elem>{$prod/name}</elem>",
      ["<elem><name language=\"en\">Floppy Sun Hat</name></elem>", "<elem><name language=\"en\">Deluxe Travel Bag</name></elem>"]),
    #check without where and order
    TestCase.new('for $prod in doc("catalog.xml")/catalog/product  return <elem>{$prod/name}</elem>',
      ['<elem><name language="en">Fleece Pullover</name></elem>', "<elem><name language=\"en\">Floppy Sun Hat</name></elem>", "<elem><name language=\"en\">Deluxe Travel Bag</name></elem>", '<elem><name language="en">Cotton Dress Shirt</name></elem>']),
    #check text
    TestCase.new('for $prod in doc("catalog.xml")/catalog/product[2]  return <elem>{$prod/name/text()}</elem>',
      ['<elem>Floppy Sun Hat</elem>']),
    #check let
    TestCase.new('for $prod in doc("catalog.xml")/catalog/product[2] let $name := $prod/name  return <elem>{$name/text()}</elem>',
      ['<elem>Floppy Sun Hat</elem>']),
    #let
    TestCase.new("for $prod in doc(  \"catalog.xml\"  )/catalog/product[position()<=3] let $name := $prod/name where $prod/@dept<=\"ACC\" order by $name return <elem>{$name}</elem>",
      ["<elem><name language=\"en\">Deluxe Travel Bag</name></elem>", "<elem><name language=\"en\">Floppy Sun Hat</name></elem>"]),
    #all
    TestCase.new(
      'for $p in doc("catalog.xml")/catalog/product
       let $n := $p/name
       where $n/@language eq "en"
       order by $n
       return <names>{$n/text()}</names>',
      ['<names>Cotton Dress Shirt</names>', '<names>Deluxe Travel Bag</names>', '<names>Fleece Pullover</names>', '<names>Floppy Sun Hat</names>']
    ),
    TestCase.new(
      'for $p in doc("catalog.xml")/catalog/product
       let $n := $p/name
       where $n/@language ne "een"
       order by $n
       return $n/text()',
      ['Cotton Dress Shirt', 'Deluxe Travel Bag', 'Fleece Pullover', 'Floppy Sun Hat']
    ),
    TestCase.new(
      'for $p in doc("catalog.xml")/catalog/product
       let $n := $p/name
       where $n/@language ne "een"
       order by $n
       return $p/name/text()',
      ['Cotton Dress Shirt', 'Deluxe Travel Bag', 'Fleece Pullover', 'Floppy Sun Hat']
    ),
    #multiple result occurence
    TestCase.new(
      'for $p in doc("catalog.xml")/catalog/product
       let $n := $p/name
       where $n/@language ne "een"
       order by $n
       return <elem att="{$p/name}" nextattr="{$p/number/text()}">{$p/name}</elem>',
      ['<elem att="Cotton Dress Shirt" nextattr="784"><name language="en">Cotton Dress Shirt</name></elem>',
       '<elem att="Deluxe Travel Bag" nextattr="443"><name language="en">Deluxe Travel Bag</name></elem>',
       '<elem att="Fleece Pullover" nextattr="557cdata cast<>"><name language="en">Fleece Pullover</name></elem>',
       '<elem att="Floppy Sun Hat" nextattr="563"><name language="en">Floppy Sun Hat</name></elem>']
    ),
    TestCase.new(
      'for $p in doc("catalog.xml")/catalog/product
       let $n := $p/name
       where $n/@language ne "een"
       order by $n
       return <elem att="{$p/name}" nextattr="{$p/number}">{$p/name/text()}</elem>',
      ['<elem att="Cotton Dress Shirt" nextattr="784">Cotton Dress Shirt</elem>',
       '<elem att="Deluxe Travel Bag" nextattr="443">Deluxe Travel Bag</elem>',
       '<elem att="Fleece Pullover" nextattr="557cdata cast<>">Fleece Pullover</elem>',
       '<elem att="Floppy Sun Hat" nextattr="563">Floppy Sun Hat</elem>']
    ),
    #overal wrap
    TestCase.new(
      '<ul>{for $p in doc("catalog.xml")/catalog/product
       let $n := $p/name
       where $n/@language ne "een"
       order by $n
       return <elem att="{$p/name}" nextattr="{$p/number}">{$p/name/text()}</elem>}</ul>',
      ['<ul><elem att="Cotton Dress Shirt" nextattr="784">Cotton Dress Shirt</elem><elem att="Deluxe Travel Bag" nextattr="443">Deluxe Travel Bag</elem><elem att="Fleece Pullover" nextattr="557cdata cast<>">Fleece Pullover</elem><elem att="Floppy Sun Hat" nextattr="563">Floppy Sun Hat</elem></ul>']
    ),
    TestCase.new(
      '<ul>{for $p in doc("catalog.xml")/catalog/product
       let $n := $p/name
       where $n/@language ne "een"
       order by $n
       return <elem att="{$p/name/text()}" nextattr="{$p/number/text()}">{$p/name/text()}</elem>}</ul>',
      ['<ul><elem att="Cotton Dress Shirt" nextattr="784">Cotton Dress Shirt</elem><elem att="Deluxe Travel Bag" nextattr="443">Deluxe Travel Bag</elem><elem att="Fleece Pullover" nextattr="557cdata cast<>">Fleece Pullover</elem><elem att="Floppy Sun Hat" nextattr="563">Floppy Sun Hat</elem></ul>']
    ),
    
  ]
  
  
  
  def test_xquery
    
    xquery_test_helper = XQueryTestHelper.new
    xquery_test_helper.create_test_file
    
    xquery_controller = XQuery::XQueryController.new(XQueryTestHelper::ENV_NAME, XQueryTestHelper::COLL_NAME)
    
    TEST_CASES.each_with_index { |test_case, index|
      new_results = xquery_controller.get_results(test_case.query)
      right_results = test_case.results
      
      assert_equal(right_results.length, new_results.length, "for query: #{test_case.query}, result count not the same")
      
      right_results.each_with_index { |right_result, indx|
        new_result = new_results[indx]
        if(new_result.kind_of?(Nokogiri::XML::Node))
          new_result = new_result.to_html
        end
        assert_equal(right_result, new_result, "for query: #{test_case.query}, results are not the same")
      }
      
      puts "test #{index+1}/#{TEST_CASES.length} ok"
      
    }
    
    xquery_test_helper.cleanup_test_file
    
  end
  
end
