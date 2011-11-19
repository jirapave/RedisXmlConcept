require_relative "node"

module XML
  #This is strange, Node has descendants=other nodes, TextContent is node, why does it have
  #parts? It should be just plain text no?
  class TextContent < XML::Node
    def initialize(parts=false, text_content=false)
      parts ||= []
      @parts = parts
      @text_content = text_content
    end
    
    def to_text
      result = "";
      @parts.each do |part|
        result += part
      end
    end
  end
end