require_relative "path_processor"
require_relative "../../base_interface/db_interface"
require_relative "../../transformer/key_element_builder"
require_relative "../../transformer/key_builder"
require_relative "../../transformer/mapping_service"

module XQuery
  class KeyPathProcessor < PathProcessor
    
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
      return incomming.kind_of?(Transformer::KeyElementBuilder) || incomming.kind_of?(Transformer::KeyBuilder) 
    end
    
    #stripped: true/false
    def get_text(key)
      return get_texts(key).join
    end
    
    def get_descendant_texts(key)
      results = [ get_text(key) ]
      descendants = get_desc_elements(key)
      descendants.each { |desc|
        results << get_text(desc, stripped)
      }
      return results
    end
    
    def get_node_content(key)
      content = ""
      key_array = get_children_plain(key)
      key_array.each { |key|
        if(Transformer::KeyElementBuilder.element?(key))
          content << get_node(Transformer::KeyElementBuilder.build_from_s(@key_builder, key)).to_stripped_s
        else
          content << @db.get_hash_value(@content_hash_key, key)
        end          
      }
      return content
    end
    
    def get_children_elements(key, match_elem_name="*")
      key_array = []
      match_elem_id = match_elem_name
      if(match_elem_name != "*")
        match_elem_id = get_elem_index(match_elem_name)
      end
      
      get_children_plain(key).each { |str_key|
          if(Transformer::KeyElementBuilder.element?(str_key))
            new_key = Transformer::KeyElementBuilder.build_from_s(@key_builder, str_key)
            #check match_elem_name
            if(match_elem_id == "*" || new_key.elem_id == match_elem_id)
              key_array << new_key
            end
          end
        }
      return key_array
    end
    
    def get_descendant_elements(key, match_elem_name="*")
      match_elem_id = match_elem_name
      if(match_elem_name != "*")
        match_elem_id = get_elem_index(match_elem_name)
      end
      
      all_keys = get_desc_elements(key)
      key_array = []
      all_keys.each { |new_key|
        if(match_elem_id == "*" || new_key.elem_id == match_elem_id)
          key_array << new_key
        end
      }
      
      return key_array
    end
    
    def get_node(key)
      # if(key.kind_of?(String) && Transformer::KeyElementBuilder.text?(key))
        # return XML::TextContent.new(@db.find_value(key), -1, XML::TextContent::PLAIN)
      # end
      return @xml_transformer.get_node(key)
    end
    
    def get_attribute(key, attr_name)
      # attr_hash = @xml_transformer.get_attributes(key) #TODO resolve with Pavel
      attr_hash = get_attribute_hash(key)
      puts "ATTR HASH: #{attr_hash.inspect}"
      return attr_hash[get_attr_index(attr_name)]
    end
    
    
  private
    def get_attribute_hash(key)
      attribute_hash = Hash.new
      list_str = @db.get_hash_value(@content_hash_key, key.attr)
      if(list_str == nil)
        return attribute_hash #empty hash
      end
      fields_only = []
      values_only = []
      list_str.split('|').each_with_index { |x, index|
        fields_only << x if(index%2 == 0)
        values_only << x if(index%2 != 0)
      }
      fields_only.each_with_index { |field, index|
        attribute_hash[field] = values_only[index]
      }
      return attribute_hash
    end
    
    def get_desc_elements(key)
      start_key_array = []
      if(key.kind_of?(Transformer::KeyElementBuilder))
        start_key_array.concat(get_children_elements(key))
      else
        start_key_array << @root_key
      end
      
      all_round_keys = []
      all_round_keys.concat(start_key_array)
      start_key_array.each { |start_key|
        all_round_keys.concat(get_descendant_elements(start_key))
      }
      
      return all_round_keys
    end
  
    def get_children_plain(key)#String Array
      values = []
      
      if(key.kind_of?(Transformer::KeyBuilder))
        return [ @root_key.to_s ]
      end
      
      list_str = @db.get_hash_value(@content_hash_key, key)
      if(list_str == nil)
        raise StandardError, "wrong key or content hash_key, nil found instead of descendants, hash_key: #{@content_hash_key}, key: #{key}"
      end
      list_str.split('|').each { |value|
        values << value if(!value.empty?)
      }
      return values
    end
    
    def get_texts(key)
      texts = []
      key_array = get_children_plain(key)
      key_array.each { |key|
        if(Transformer::KeyElementBuilder.text?(key) || Transformer::KeyElementBuilder.cdata?(key))
          t = @db.get_hash_value(@content_hash_key, key)
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