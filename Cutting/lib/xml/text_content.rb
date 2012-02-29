require_relative "node"

module XML
  class TextContent < XML::Node
    attr_accessor :text_content
    def initialize(parts=false, text_content=false, order)
      #TODO refactoring, parts not needed anymore?
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