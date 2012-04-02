require_relative "node"

module XML
  # Class represents Text node including it's order and type (plain, comment and cdata)
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