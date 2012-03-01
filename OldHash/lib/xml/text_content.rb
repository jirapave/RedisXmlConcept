require_relative "node"

module XML
  class TextContent < XML::Node
    attr_accessor :text_content
    def initialize(text_content=false, order)
      @text_content = text_content
      @order = order
    end
  end
end