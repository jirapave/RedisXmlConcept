require_relative "node"

module XML
  #This is strange, Node has descendants=other nodes, TextContent is node, why does it have
  #parts? It should be just plain text no?
  class TextContent < XML::Node
    attr_accessor :text_content
    def initialize(parts=false, text_content=false, order)
      parts ||= []
      @parts = parts
      @text_content = text_content
      @order = order
    end
    
    def to_text
      result = "";
      @parts.each do |part|
        result += part
      end
    end
  end
end