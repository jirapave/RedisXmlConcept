require_relative "node"

module XML
  class TextContent < XML::Node
    attr_accessor :text_content, :order, :type
    
    PLAIN = 1
    COMMENT = 2
    CDATA = 3
    
    def initialize(text_content=false, order, type)
      @text_content = text_content
      @order = order
      @type = type
    end
  end
end