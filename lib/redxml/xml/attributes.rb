module XML
  class Attributes
    attr_accessor :attrs, :node
    def initialize(node, attrs=false)
      key = ""
      value = ""
      attrs ||= {}
      @attrs = attrs
      @node = node
    end
    
    def get_attr(name)
      result = nil
      @attrs.each do |key, value|
        if key == name
          result = value
        end
      end
      return result
    end
    
    def length()
      @attrs.length
    end
  end
end