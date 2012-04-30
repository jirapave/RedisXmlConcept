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
      
      return ExpressionModule.create_expr(xml_doc)
      
    end
    
  end
end