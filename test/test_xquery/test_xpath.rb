require "test/unit"
require_relative "xquery_test_helper"
if File.basename($0) == "#{File.basename(__FILE__)}"
  require_relative "../../lib/redxml.rb"
else
  require "redxml"
end


class TestXPath < Test::Unit::TestCase
  
  class TestCase
    
    attr_reader :query, :results
    
    def initialize(query, results)
      @query = query
      @results = results
    end
  end
  
  TEST_CASES = [
    TestCase.new('doc("catalog.xml")/catalog/product[colorChoices][number gt "500"][@dept = "MEN"]/colorChoices',
      ['<colorChoices>white gray</colorChoices>']),
    TestCase.new('doc("catalog.xml")/catalog/product[colorChoices][number gt "500"][@dept = "WMN"]/colorChoices',
      ['<colorChoices no="four">navy black</colorChoices>']),
    TestCase.new("doc(  \"catalog.xml\"  )/catalog/product[colorChoices][number=784]/number",
      ['<number>784</number>']),
    TestCase.new("doc(  \"catalog.xml\"  )/catalog/product[colorChoices]/number",
      ['<number>557<![CDATA[cdata cast<>]]></number>', '<number>784</number>']),
    TestCase.new("doc(  \"catalog.xml\"  )/catalog/product/colorChoices[@no]",
      ['<colorChoices no="four">navy black</colorChoices>']),
    TestCase.new("doc(  \"catalog.xml\"  )/catalog/product[1]/@dept",
      ["WMN"]),
    TestCase.new("doc(  \"catalog.xml\"  )/catalog/product/number[. = 443]",
      ["<number>443</number>"]),
    TestCase.new("doc(  \"catalog.xml\"  )/catalog/product/number[. eq '443']",
      ["<number>443</number>"]),
    TestCase.new("doc(  \"catalog.xml\"  )/catalog/product/name",
      ['<name language="en">Fleece Pullover</name>', '<name language="en">Floppy Sun Hat</name>', '<name language="en">Deluxe Travel Bag</name>', '<name language="en">Cotton Dress Shirt</name>']),
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
      ["<product dept=\"MEN\">\n  <number>784</number>\n  <name language=\"en\">Cotton Dress Shirt</name>\n  <colorChoices>white gray</colorChoices>\n  <desc>Our<i>favorite</i>shirt!<!--Second commentary--></desc>\n</product>"]),
    TestCase.new("doc(\"catalog.xml\")//product[position() >= 4]",
      ["<product dept=\"MEN\">\n  <number>784</number>\n  <name language=\"en\">Cotton Dress Shirt</name>\n  <colorChoices>white gray</colorChoices>\n  <desc>Our<i>favorite</i>shirt!<!--Second commentary--></desc>\n</product>"]),
    TestCase.new("doc(\"catalog.xml\")//product[position() > 3]",
      ["<product dept=\"MEN\">\n  <number>784</number>\n  <name language=\"en\">Cotton Dress Shirt</name>\n  <colorChoices>white gray</colorChoices>\n  <desc>Our<i>favorite</i>shirt!<!--Second commentary--></desc>\n</product>"]),
    TestCase.new("doc(\"catalog.xml\")//product[3 < position()]",
      ["<product dept=\"MEN\">\n  <number>784</number>\n  <name language=\"en\">Cotton Dress Shirt</name>\n  <colorChoices>white gray</colorChoices>\n  <desc>Our<i>favorite</i>shirt!<!--Second commentary--></desc>\n</product>"]),
    TestCase.new("doc(\"catalog.xml\")//product[last()]/name/text()",
      ["Cotton Dress Shirt"]),
    TestCase.new("doc(\"catalog.xml\")/catalog/product[name = \"Fleece Pullover\"]/number/text()",
      ["557cdata cast<>"]),
  ]
  
  
  def test_xpath
    
    xquery_test_helper = XQueryTestHelper.new
    xquery_test_helper.create_test_file
    
    xquery_controller = XQuery::XQueryController.new(XQueryTestHelper::ENV_NAME, XQueryTestHelper::COLL_NAME)
    
    TEST_CASES.each_with_index { |test_case, index|
      # puts "QUERY: #{test_case.query}"
      new_results = xquery_controller.get_results(test_case.query)
      right_results = test_case.results
      
      assert_equal(right_results.length, new_results.length, "for query: #{test_case.query}, result count not the same")
      
      right_results.each_with_index { |right_result, indx|
        new_result = new_results[indx]
        if(new_result.kind_of?(Nokogiri::XML::Node))
          new_result = new_result.to_s
        end
        assert_equal(right_result, new_result, "for query: #{test_case.query}, results are not the same")
      }
      
      puts "test #{index+1}/#{TEST_CASES.length} ok"
      
    }
    
    xquery_test_helper.cleanup_test_file
    
  end
  
end
