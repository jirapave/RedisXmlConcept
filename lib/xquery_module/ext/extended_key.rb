require_relative "../../transformer/key_element_builder"

module XQuery
  class ExtendedKey
    
    #types
    ELEMENT = :ELEMENT
    TEXT = :TEXT
    COMMENT = :COMMENT
    CDATA = :CDATA
    DOCUMENT = :DOCUMENT
    
    attr_accessor :key_builder, :key_element_builder, :parent_key, :parent_children_array, :type
    
    def initialize(key_builder)
      @key_builder = key_builder
      @key_element_builder = nil
      @key_str = nil
      @parent_key = nil
      @parent_children_array = nil
      @type = DOCUMENT
    end
    
    def self.build_from_key(key_element_builder, parent_key, parent_value)
      instance = ExtendedKey.new(key_element_builder.key_builder)
      instance.key_element_builder = key_element_builder
      instance.key_str = key_element_builder.to_s
      instance.parent_key = parent_key
      instance.parent_value = parent_value
      instamce.type = ELEMENT
      return instance
    end
    
    
    def self.build_from_s(key_str, key_builder, parent_key, parent_value, key_element_builder=nil)
      instance = ExtendedKey.new(key_builder)
      if(key_element_builder == nil)
        instance.key_element_builder = Transformer::KeyElementBuilder.build_from_s(key_builder, key_str)
      else
        instance.key_element_builder = key_element_builder
      end  
      instance.key_str = key_str
      type = Transformer::KeyElementBuilder.text_type(key_str)
      case type
      when XML::TextContent::PLAIN
        instance.type = TEXT
      when XML::TextContent::COMMENT
        instance.type = COMMENT
      when XML::TextContent::CDATA
        instance.type = CDATA
      else
        instance.type = ELEMENT
      end
      instance.parent_key = parent_key
      instance.parent_value = parent_value
    end
    
  end
end