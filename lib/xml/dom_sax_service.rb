require "rubygems"
require "nokogiri"

module XML
  class DomSaxService
    def initialize()
      
    end
    
    # Generate SAX event into SAX handler based on contet in DOM Document paased in parameter
    # ==== Parameters
    # * +sax_handler+ - SAX handler to handle events, expecting Nokogiri::XML::SAX::Document
    # * +document+ - Nokogiri::XML::Document based on which the events should be generated
    def generate_sax_from_dom(sax_handler, document)
      parser = Nokogiri::XML::SAX::Parser.new(sax_handler)
      parser.parse("#{document}")
    end
  end
end