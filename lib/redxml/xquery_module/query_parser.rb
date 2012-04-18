require_relative "parser_extension/Parsers"
require_relative "expression/expression_module"
require "rubygems"
require "nokogiri"
require "singleton"

module XQuery
  class QueryParser
    include Singleton
    
    def initialize
      @parser = Parsers::UpdateParser.new()
    end
    
    
    
    def parse(query)
      str = @parser.parse_XQuery(query)
      
      xml_doc = Nokogiri.XML(str) do |config|
        config.default_xml.noblanks
      end
      
      puts "QUERY: #{xml_doc.text}"
      
      #debug TODO delete
      # puts "getsome: #{str}"
      # puts xml_doc.to_xml(:ident => 2)
      # puts "query: #{query}"
      
      return ExpressionModule.create_expr(xml_doc)
      
    end
    
  end
end


#testing
# XQuery::QueryParser.instance.parse('<ul>{for $p in doc("catalog.xml")/catalog/product
       # let $n := $p/name
       # where $n/@language ne "een"
       # order by $n
       # return <elem att="{$p/name}" nextattr="{$p/number}">{$p/name/text()}</elem>}</ul>')
# XQuery::QueryParser.parse_update('')
# XQuery::QueryParser.parse_update('for $prod in doc("catalog.xml")/catalog/product/number return <n>{$prod/neco}</n>')
# XQuery::QueryParser.parse_update('doc("catalog.xml")/catalog/product[colorChoices]')
# XQuery::QueryParser.parse_update('insert nodes (attribute A { 2.1 }, <child1 attr1="val1" attr2="val2"><name>text</name><name>text</name></child1>, "text") into doc("catalog.xml")/catalog/product[1]')
# XQuery::QueryParser.parse_update('insert node doc("catalog.xml")/product/name as first into doc("catalog.xml")/root')
# XQuery::QueryParser.parse_update('for $prod in doc("catalog.xml")/catalog/product/number[. = 333] let $name := $prod/name  where $prod/@dept = "ACC"    order by $x/title      return delete node $name')
# XQuery::QueryParser.parse_update('delete node doc("catalog.xml")/root/product')
# XQuery::QueryParser.parse_update('for $prod in doc("catalog.xml")/catalog/product/number[. = 333] let $name := $prod/name  where $prod/@dept = "ACC"    order by $x/title      return $x')
# XQuery::QueryParser.parse_update('for $prod in doc("catalog.xml")/catalog/product/number[. = 333] let $name := $prod/name  where $prod/@dept = "ACC"    order by $x/title      return  $name ')
# XQuery::QueryParser.parse_update('for $title in collection("/allbooks")//SECTION/TITLE 
# return rename node $title as SECTION_TITLE')
# XQuery::QueryParser.parse_update('$title')
# XQuery::QueryParser.parse_query("$prod")
# XQuery::QueryParser.parse_xquery("for $prod in doc( \"catalog.xml\")/catalog/product/number[.=333][@dept gt 56] let $name:=$prod/name where $prod/@dept=\"ACC\" order by $x/title return $name")
# XQuery::QueryParser.parse_query("for $prod in doc( \"catalog.xml\")/catalog/product/number[2][@dept gt 56] let $name:=$prod/name where $prod/@dept=\"ACC\" order by $x/title return $name")
# XQuery::QueryParser.parse_query("doc( \"catalog.xml\")/catalog/product/number[2][no = 56][@dept = 'ACC'][. > 56][position() gt 57]")
# puts XQuery::QueryParser.parse_query("doc( \"catalog.xml\")/catalog/product/number[1]")
#testing