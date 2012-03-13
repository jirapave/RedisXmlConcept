require_relative "parser_extension/Parsers"
require_relative "expression/expression_module"
require "rubygems"
require "nokogiri"

module XQuery
  class QueryParser
    
    def self.parse_xquery(query)
      parser = Parsers::XQueryParser.new(query);
      str = parser.parse_XQuery();
      
      xml_doc = Nokogiri.XML(str) do |config|
        config.default_xml.noblanks
      end
      
      #debug TODO delete
      puts "getsome: #{str}"
      puts xml_doc.to_xml(:ident => 2)
      puts "query: #{query}"
      
      return ExpressionModule.create_expr(xml_doc)
    end
    
    def self.parse_update(query)
      parser = Parsers::UpdateParser.new(query)
      str = parser.parse_XQuery();
      
      xml_doc = Nokogiri.XML(str) do |config|
        config.default_xml.noblanks
      end
      
      #debug TODO delete
      puts "getsome: #{str}"
      puts xml_doc.to_xml(:ident => 2)
      puts "query: #{query}"
      
    end
    
    
    
  end
end


#testing
# XQuery::QueryParser.parse_update('for $prod in doc("catalog.xml")/catalog/product/number[. = 333] let $name := $prod/name  where $prod/@dept = "ACC"    order by $x/title      return rename node $name as HELL')
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