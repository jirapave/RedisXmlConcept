require_relative "attr"

module XML
  class Attributes
    attr_accessor :attributes, :node
    def initialize(node, attributes=false)
      attributes ||= []
      @attributes = attributes
      @node = node
    end
    
    def get_attr(name)
      
    end
    
    def length()
      @attributes.length
    end
  end
end