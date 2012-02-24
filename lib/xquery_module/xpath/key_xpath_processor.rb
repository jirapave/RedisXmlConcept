require_relative "xpath_processor"
require_relative "../../base_interface/db_interface"
require_relative "../../transformer/key_element_builder"
require_relative "../../transformer/key_builder"
require_relative "../../transformer/mapping_service"

module XQuery
  class KeyXPathProcessor < XPathProcessor
    
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
      # @xml_transformer.database = key.db_name
      # @xml_transformer.collection = key.col_name
      # @xml_transformer.mapping = @mapping_hash
      # @xml_transformer.content_hash = @content_hash_key
      
      #load root key - KeyElementBuilder object
      @root_key = Transformer::KeyElementBuilder.create(key_builder, info_hash["root"], false)
      
    end
    
    
    
    #stripped: true/false
    def get_text(key, stripped)
      text = ""
      key_array = get_children_plain(key)
      key_array.each { |key|
        if(Transformer::KeyElementBuilder.text?(key))
          t = @db.get_hash_value(@content_hash_key, key)
          t = t.strip if(stripped)
          text << t
        end          
      }
      return text
    end
    
    def get_node_content(key)
      content = ""
      key_array = get_children_plain(key)
      key_array.each { |key|
        if(Transformer::KeyElementBuilder.text?(key))
          content << @db.get_hash_value(@content_hash_key, key)
        else
          content << get_node(Transformer::KeyElementBuilder.build_from_s(key)).to_stripped_s
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
          if(!Transformer::KeyElementBuilder.text?(str_key))
            new_key = Transformer::KeyElementBuilder.build_from_s(@key_builder, str_key)
            #check match_elem_name
            if(match_elem_id == "*" || new_key.elem_name == match_elem_id)
              key_array << new_key
            end
          end
        }
      return key_array
    end
    
    def get_descendant_elements(key)
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
    
    def get_node(key)
      return @xml_transformer.find_node(key)
    end
    
    def get_attribute(key, attr_name)
      attr_hash = @xml_transformer.get_attributes(key)
      return attr_hash[get_attr_index(attr_name)]
    end
    
    
  private
    # def get_attribute_hash(key)
      # attribute_hash = Hash.new
      # list_str = @db.get_hash_value(@content_hash_key, key.attr)
      # if(list_str == nil)
        # return attribute_hash #empty hash
      # end
      # fields_only = []
      # values_only = []
      # list_str.split('"').each_with_index { |x, index|
        # fields_only << x if(index%2 == 0)
        # values_only << x if(index%2 != 0)
      # }
      # fields_only.each_with_index { |field, index|
        # attribute_hash[field] = values_only[index]
      # }
      # return attribute_hash
    # end
  
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
    
    def get_elem_index(elem_name)
      @mapping_service.map_elem_name(elem_name)
    end
    
    def get_attr_index(attr_name)
      @mapping_service.map_attr_name(attr_name)
    end
    
  end
  
  
end