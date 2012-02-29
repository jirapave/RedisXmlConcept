require_relative "attr"

module XML
  class Attributes
    attr_accessor :attributes, :node
    def initialize(node, attributes=false)
      attributes ||= []
      key = ""
      value = ""
      attributes ||= []
      @attributes = {}
      attributes.each do |attr|
        #TODO according to Nokogiri...attributes can also have prefixes etc.
        @attributes[attr.localname] = attr.value
      end
      
      @node = node
    end
    
    def get_attr(name)
      
    end
    
    def length()
      @attributes.length
    end
  end
end