require_relative "path_processor"
require_relative "../ext/extended_key"
require_relative "../../base_interface/db_interface"
require_relative "../../transformer/key_element_builder"
require_relative "../../transformer/key_builder"
require_relative "../../transformer/mapping_service"


#TODO dodelat!!! zkontrolovat!

module XQuery
  class KeyPathProcessor < PathProcessor
    
    CHILDREN_SEPARATOR = '|'
    
    #key - Key object
    def initialize(key_builder)
      @db = BaseInterface::DBInterface.instance
      @key_builder = key_builder
      
      #load file hashes
      @mapping_service = Transformer::MappingService.new(key_builder)
      @content_hash_key = key_builder.content_key
      info_hash = @db.find_value(key_builder.info)
      
      #init xml transformer
      @xml_transformer = Transformer::XMLTransformer.new(key_builder)
      
      #load root key - KeyElementBuilder object
      @root_key = Transformer::KeyElementBuilder.new(key_builder, info_hash["root"])
      
    end
    
    
    
    def valid_elem?(incomming) #return true/false
      return incomming.kind_of?(ExtendedKey)
      # return incomming.kind_of?(Transformer::KeyElementBuilder) || incomming.kind_of?(Transformer::KeyBuilder) 
    end
    
    def get_text(extended_key)
      return get_texts(extended_key).join
    end
    
    def get_descendant_texts(extended_key)
      results = [ get_text(extended_key) ]
      descendants = get_desc_elements(extended_key)
      descendants.each { |desc|
        results << get_text(desc)
      }
      return results
    end
    
    def get_node_content(extended_key)
      content = ""
      key_array = get_children_plain(extended_key)
      key_array.each { |key_str|
        if(Transformer::KeyElementBuilder.element?(key_str))
          content << get_node(Transformer::KeyElementBuilder.build_from_s(@key_builder, key_str)).to_stripped_s
        else
          content << @db.get_hash_value(@content_hash_key, key_str)
        end
      }
      return content
    end
    
    def get_children_elements(extended_key, match_elem_name="*")
      key_array = []
      match_elem_id = match_elem_name
      if(match_elem_name != "*")
        match_elem_id = get_elem_index(match_elem_name)
      end
      
      children_array = get_children_plain(extended_key)
      if(children_array == nil)
        #extended_key is DOCUMENT key
        return [ ExtendedKey.build_from_key(@root_key, nil, nil) ]
      end
      
      children_array.each { |key_str|
        if(Transformer::KeyElementBuilder.element?(key_str))
          new_key = Transformer::KeyElementBuilder.build_from_s(@key_builder, key_str)
          #check match_elem_name
          if(match_elem_id == "*" || new_key.elem_id == match_elem_id)
            new_extended_key = ExtendedKey.build_from_key(new_key, extended_key.key_str, children_array)
            key_array << new_extended_key
          end
        end
      }
      return key_array
    end
    
    def get_descendant_elements(extended_key, match_elem_name="*")
      match_elem_id = match_elem_name
      if(match_elem_name != "*")
        match_elem_id = get_elem_index(match_elem_name)
      end
      
      all_keys = get_desc_elements(extended_key)
      key_array = []
      all_keys.each { |new_key|
        if(match_elem_id == "*" || new_key.key_element_builder.elem_id == match_elem_id)
          key_array << new_key
        end
      }
      
      return key_array
    end
    
    def get_node(extended_key)
      # if(extended_key.kind_of?(String) && Transformer::KeyElementBuilder.text?(extended_key))
        # return XML::TextContent.new(@db.find_value(extended_key), -1, XML::TextContent::PLAIN)
      # end
      puts "GETTING NODE key=#{extended_key.key_element_builder.to_s}"
      return @xml_transformer.get_node(extended_key.key_element_builder)
    end
    
    def get_attribute(extended_key, attr_name)
      attr_hash = @xml_transformer.get_attributes(extended_key.key_element_builder, false) #TODO resolve with Pavel
      # attr_hash = get_attribute_hash(extended_key.key_element_builder)
      if(!attr_hash)
        return nil
      end
      puts "ATTRS: #{attr_hash.inspect}"
      return attr_hash[get_attr_index(attr_name)]
    end
    
  protected
    attr_accessor :content_hash_key
    
  private
    def get_attribute_hash(key)
      attribute_hash = Hash.new
      list_str = @db.get_hash_value(@content_hash_key, key.attr)
      if(list_str == nil)
        return attribute_hash #empty hash
      end
      fields_only = []
      values_only = []
      list_str.split('"').each_with_index { |x, index|
        fields_only << x if(index%2 == 0)
        values_only << x if(index%2 != 0)
      }
      fields_only.each_with_index { |field, index|
        attribute_hash[field] = values_only[index]
      }
      return attribute_hash
    end
    
    def get_desc_elements(extended_key)
      start_key_array = []
      start_key_array.concat(get_children_elements(extended_key))
      # if(extended_key.kind_of?(Transformer::KeyElementBuilder))
        # start_key_array.concat(get_children_elements(extended_key))
      # else
        # start_key_array << @root_key
      # end
      
      all_round_keys = []
      all_round_keys.concat(start_key_array)
      start_key_array.each { |start_key|
        all_round_keys.concat(get_desc_elements(start_key))
      }
      
      return all_round_keys
    end
    
    def get_plainly_children(key_str)
      puts "getting plainly children key: #{key_str}"
      list_str = @db.get_hash_value(@content_hash_key, key_str)
      puts "got: #{list_str}"
      if(list_str == nil)
        raise StandardError, "wrong key or content hash_key, nil found instead of descendants, hash_key: #{@content_hash_key}, key: #{key_str}"
      end
      
      #TODO experimental shortage - check!
      values = list_str.split(CHILDREN_SEPARATOR)
      # list_str.split(CHILDREN_SEPARATOR).each { |value|
        # values << value if(!value.empty?)
      # }
      return values
    end
    
    def get_children_plain(extended_key)#String Array
      if(extended_key.type == ExtendedKey::DOCUMENT)
        
        return nil
      end
      
      return get_plainly_children(extended_key.key_element_builder.to_s)
      
      # list_str = @db.get_hash_value(@content_hash_key, extended_key.key_element_builder)
      # if(list_str == nil)
        # raise StandardError, "wrong key or content hash_key, nil found instead of descendants, hash_key: #{@content_hash_key}, key: #{key}"
      # end
#       
      # #TODO experimental shortage - check!
      # values = list_str.split(CHILDREN_SEPARATOR)
      # # list_str.split(CHILDREN_SEPARATOR).each { |value|
        # # values << value if(!value.empty?)
      # # }
      # return values
    end
    
    def get_texts(extended_key)
      texts = []
      key_array = get_children_plain(extended_key)
      if(key_array == nil)
        return [ "" ]
      end
      key_array.each { |key_str|
        case Transformer::KeyElementBuilder.text_type(key_str)
        when XML::TextContent::PLAIN, XML::TextContent::CDATA
          t = @db.get_hash_value(@content_hash_key, key_str)
          texts << t
        end
      }
      return texts
    end
    
    def get_elem_index(elem_name)
      @mapping_service.map_elem_name(elem_name)
    end
    
    def get_attr_index(attr_name)
      @mapping_service.map_attr_name(attr_name)
    end
    
  end
  
  
end