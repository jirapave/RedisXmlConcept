require_relative "xquery_test_helper"
if File.basename($0) == "#{File.basename(__FILE__)}"
  require_relative "../../lib/redxml.rb"
else
  require "redxml"
end
require "test/unit"

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
    
    #DELETE
    TestCase.new(
      'doc("catalog.xml")/catalog/product[3]/name/text()',
      [ "Deluxe Travel Bag" ],
      'delete node doc("catalog.xml")/catalog/product[3]',
      [ "Cotton Dress Shirt" ]
    ),
    TestCase.new(
      'doc("catalog.xml")/catalog/product[2]/name/text()',
      [ "Floppy Sun Hat" ],
      'for $prod in doc("catalog.xml")/catalog/product where $prod[nocdata]/number = 563 return delete node $prod',
      [ "Deluxe Travel Bag" ]
    ),
    TestCase.new(
      'doc("catalog.xml")/catalog/product[1]/name/text()',
      [ "Fleece Pullover" ],
      'for $prod in doc("catalog.xml")/catalog/product
       where $prod/@dept != "MEN"
       return delete nodes $prod',
      [ "Cotton Dress Shirt" ]
    ),
    TestCase.new(
      'doc("catalog.xml")/catalog/product[1]/name/text()',
      [ "Fleece Pullover" ],
      'delete nodes doc("catalog.xml")/catalog/product[@dept != "MEN"]',
      [ "Cotton Dress Shirt" ]
    ),

    # INSERT
    #attr
    TestCase.new(
      'doc("catalog.xml")/catalog/product[1]/@dept',
      ["WMN"],
      'insert nodes attribute dept { "something" } into doc("catalog.xml")/catalog/product[1]',
      ["something"]
    ),
    TestCase.new(
      'doc("catalog.xml")/catalog/product[1]/@att',
      [],
      'insert nodes attribute att { "something" } into doc("catalog.xml")/catalog/product[1]',
      ["something"]
    ),
    #elem
    TestCase.new(
      'doc("catalog.xml")/catalog/product[1]/added/name[@at eq "some"]/text()',
      [],
      'insert nodes <added><name at="some">some text</name></added> into doc("catalog.xml")/catalog/product[1]',
      ['some text']
    ),
    #check into as...
    TestCase.new(
      'doc("catalog.xml")/catalog/product[4]/*[last()]/name[@at eq "some"]/text()',
      [],
      'insert nodes <added><name at="some">some text</name></added> as last into doc("catalog.xml")/catalog/product[4]',
      ['some text']
    ),
    TestCase.new(
      'doc("catalog.xml")/catalog/product[4]/*[1]/name[@at eq "some"]/text()',
      [],
      'insert nodes <added><name at="some">some text</name></added> as first into doc("catalog.xml")/catalog/product[4]',
      ['some text']
    ),
    #check after/before
    TestCase.new(
      'doc("catalog.xml")/catalog/*[5]/name[@at eq "some"]/text()',
      [],
      'insert node <added><name at="some">some text</name></added> after doc("catalog.xml")/catalog/product[4]',
      ['some text']
    ),
    TestCase.new(
      'doc("catalog.xml")/catalog/*[4]/name[@at eq "some"]/text()',
      [],
      'insert node <added><name at="some">some text</name></added> before doc("catalog.xml")/catalog/product[4]',
      ['some text']
    ),
    #check insert text
    TestCase.new(
      'doc("catalog.xml")/catalog/text()',
      [""],
      'insert node "new text" into doc("catalog.xml")/catalog',
      ['new text']
    ),
    TestCase.new(
      'doc("catalog.xml")/catalog/text()',
      [""],
      'insert node "new text" as first into doc("catalog.xml")/catalog',
      ['new text']
    ),
    TestCase.new(
      'doc("catalog.xml")/catalog/text()',
      [""],
      'insert node "new text" before doc("catalog.xml")/catalog/product[2]',
      ['new text']
    ),
    TestCase.new(
      'doc("catalog.xml")/catalog/product[2]/name/text()',
      ["Floppy Sun Hat"],
      'insert node "new text" as last into doc("catalog.xml")/catalog/product[2]/name',
      ['Floppy Sun Hatnew text']
    ),
    TestCase.new(
      'doc("catalog.xml")/catalog/product[2]/name/text()',
      ["Floppy Sun Hat"],
      'insert node "new text" as first into doc("catalog.xml")/catalog/product[2]/name',
      ['new textFloppy Sun Hat']
    ),
    TestCase.new(
      'doc("catalog.xml")/catalog/product[3]/text()',
      ["one text"],
      'insert node "two text" as first into doc("catalog.xml")/catalog/product[3]',
      ['two textone text']
    ),
    TestCase.new(
      'doc("catalog.xml")/catalog/product[3]/text()',
      ["one text"],
      'insert node "two text" as last into doc("catalog.xml")/catalog/product[3]',
      ['one texttwo text']
    ),
    TestCase.new(
      'doc("catalog.xml")/catalog/product[3]/text()',
      ["one text"],
      'insert node "two text" before doc("catalog.xml")/catalog/product[3]/number',
      ['two textone text']
    ),
    TestCase.new(
      'doc("catalog.xml")/catalog/product[3]/text()',
      ["one text"],
      'insert node "two text" before doc("catalog.xml")/catalog/product[3]/name',
      ['one texttwo text']
    ),
    TestCase.new(
      'doc("catalog.xml")/catalog/product[3]/text()',
      ["one text"],
      'insert node "two text" after doc("catalog.xml")/catalog/product[3]/name',
      ['one texttwo text']
    ),
    
    #FLWOR
    TestCase.new(
      'doc("catalog.xml")/catalog/product[2]/name/text()',
      ["Floppy Sun Hat"],
      'for $p in doc("catalog.xml")/catalog/product
       let $n := $p/name
       where $n = "Deluxe Travel Bag"
       order by $n
       return insert node $n before doc("catalog.xml")/catalog/product[2]/name',
      ['Deluxe Travel Bag', 'Floppy Sun Hat']
    ),
    #more nodes to insert
    TestCase.new(
      'doc("catalog.xml")/catalog/product[3]/name/text()',
      ["Deluxe Travel Bag"],
      'for $p in doc("catalog.xml")/catalog/product
       let $n := $p/name
       where $n/@language eq "en"
       order by $n
       return insert node $n before doc("catalog.xml")/catalog/product[3]/name',
      ['Cotton Dress Shirt', 'Deluxe Travel Bag', 'Fleece Pullover', 'Floppy Sun Hat', 'Deluxe Travel Bag']
    ),
    #check after (nodes need to be reversed for proper insertion)
    TestCase.new(
      'doc("catalog.xml")/catalog/product[3]/name/text()',
      ["Deluxe Travel Bag"],
      'for $p in doc("catalog.xml")/catalog/product
       let $n := $p/name
       where $n/@language eq "en"
       order by $n
       return insert node $n after doc("catalog.xml")/catalog/product[3]/name',
      ['Deluxe Travel Bag', 'Cotton Dress Shirt', 'Deluxe Travel Bag', 'Fleece Pullover', 'Floppy Sun Hat']
    ),
    #insertion order
    TestCase.new(
      'doc("catalog.xml")/catalog/product[3]/name/text()',
      ["Deluxe Travel Bag"],
      'for $p in doc("catalog.xml")/catalog/product
       let $n := $p/name
       where $n/@language eq "en"
       order by $n ascending
       return insert node $n after doc("catalog.xml")/catalog/product[3]/name',
      ['Deluxe Travel Bag', 'Cotton Dress Shirt', 'Deluxe Travel Bag', 'Fleece Pullover', 'Floppy Sun Hat']
    ),
    TestCase.new(
      'doc("catalog.xml")/catalog/product[3]/name/text()',
      ["Deluxe Travel Bag"],
      'for $p in doc("catalog.xml")/catalog/product
       let $n := $p/name
       where $n/@language eq "en"
       order by $n descending
       return insert node $n after doc("catalog.xml")/catalog/product[3]/name',
      ['Deluxe Travel Bag', 'Floppy Sun Hat', 'Fleece Pullover', 'Deluxe Travel Bag', 'Cotton Dress Shirt']
    ),
    TestCase.new(
      'doc("catalog.xml")/catalog/product[3]/name/text()',
      ["Deluxe Travel Bag"],
      'for $p in doc("catalog.xml")/catalog/product
       let $n := $p/name
       where $n/@language eq "en"
       order by $n descending
       return insert node $n before doc("catalog.xml")/catalog/product[3]/name',
      ['Floppy Sun Hat', 'Fleece Pullover', 'Deluxe Travel Bag', 'Cotton Dress Shirt', 'Deluxe Travel Bag']
    ),
    TestCase.new(
      'doc("catalog.xml")/catalog/product[3]/name/text()',
      ["Deluxe Travel Bag"],
      'for $p in doc("catalog.xml")/catalog/product
       let $n := $p/name
       where $n/@language eq "en"
       order by $n descending
       return insert node $n as first into doc("catalog.xml")/catalog/product[3]',
      ['Floppy Sun Hat', 'Fleece Pullover', 'Deluxe Travel Bag', 'Cotton Dress Shirt', 'Deluxe Travel Bag']
    ),
    TestCase.new(
      'doc("catalog.xml")/catalog/product[3]/name/text()',
      ["Deluxe Travel Bag"],
      'for $p in doc("catalog.xml")/catalog/product
       let $n := $p/name
       where $n/@language eq "en"
       order by $n descending
       return insert node $n as last into doc("catalog.xml")/catalog/product[3]',
      ['Deluxe Travel Bag', 'Floppy Sun Hat', 'Fleece Pullover', 'Deluxe Travel Bag', 'Cotton Dress Shirt']
    ),
    
    #inserting multiple
    TestCase.new(
      'doc("catalog.xml")/catalog/product[@ATTR = "seek"]/name/text()',
      [],
      'for $p in doc("catalog.xml")/catalog/product
       let $n := $p/name
       where $n/@language eq "en"
       order by $n descending
       return insert nodes ($n, <name>Another Name</name>, attribute ATTR { "seek" }, "twenty something") as last into doc("catalog.xml")/catalog/product[3]',
      ['Deluxe Travel Bag', 'Floppy Sun Hat', 'Fleece Pullover', 'Deluxe Travel Bag', 'Cotton Dress Shirt', 'Another Name', 'Another Name', 'Another Name', 'Another Name']
    ),
    
    
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
      test_case.before_results.each_with_index { |result, indx|
        before = before_results[indx]
        if(before.kind_of?(Nokogiri::XML::Node))
        before = before.to_s
        end
        assert_equal(result, before, "for checking query (BEFORE): #{test_case.checking_query}, results are not the same")
      }

      #perform update
      xquery_controller.get_results(test_case.update_query)
      
      #DEBUG
      puts "PRINT the document"
      xml_doc = Nokogiri.XML(xquery_controller.get_results('doc("catalog.xml")/catalog')[0].to_xml) do |config|
        config.default_xml.noblanks
      end
      puts xml_doc.to_xml(:ident => 2)

      #check results by checking query and after results
      after_results = xquery_controller.get_results(test_case.checking_query)
      assert_equal(test_case.after_results.length, after_results.length, "for checking query (AFTER): #{test_case.checking_query}, result count not the same")
      test_case.after_results.each_with_index { |result, indx|
        after = after_results[indx]
        if(after.kind_of?(Nokogiri::XML::Node))
        after = after.to_s
        end
        assert_equal(result, after, "for checking query (AFTER): #{test_case.checking_query}, results are not the same (result index: #{index})")
      }

      puts "test #{index+1}/#{TEST_CASES.length} ok"

      xquery_test_helper.cleanup_test_file

    }

  end

end
