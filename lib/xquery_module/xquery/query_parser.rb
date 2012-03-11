require_relative "../parser_extension/XQueryParser"
# require_relative "../zkouska/XQueryParser"
require_relative "expression/expression_module"
require "rubygems"
require "nokogiri"

module XQuery
  class QueryParser
    
    def self.parse_query(query)
      parser = XQueryParser::Parser.new(query);
      str = parser.parse_XQuery();
      puts "getsome: #{str}"
      # xml_doc  = Nokogiri::XML(str)
      
      xml_doc = Nokogiri.XML(str) do |config|
        config.default_xml.noblanks
      end #debug TODO delete
      puts xml_doc.to_xml(:ident => 2)
      
      puts "query: #{query}"
      
      # doc = REXML::Document.new(str)
      # doc.write($stdout, 2)
      
      return ExpressionModule.create_expr(xml_doc)
    end
    
    
    
  end
end


#testing
# XQuery::QueryParser.parse_query("for $prod in doc( \"catalog.xml\")/catalog/product/number[.=333][@dept gt 56] let $name:=$prod/name where $prod/@dept=\"ACC\" order by $x/title return $name")
# XQuery::QueryParser.parse_query("for $prod in doc( \"catalog.xml\")/catalog/product/number[2][@dept gt 56] let $name:=$prod/name where $prod/@dept=\"ACC\" order by $x/title return $name")
# XQuery::QueryParser.parse_query("doc( \"catalog.xml\")/catalog/product/number[2][no = 56][@dept = 'ACC'][. > 56][position() gt 57]")
# puts XQuery::QueryParser.parse_query("doc( \"catalog.xml\")/catalog/product/number[1]")
#testing