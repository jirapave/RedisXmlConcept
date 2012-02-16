require_relative "../base_interface/db_interface"
require_relative "../transformer/key_element_builder"


module XQuery
  class DBHelper
    
    attr_reader :root_key
    
    #key - Key object
    def initialize(key)
      @db = BaseInterface::DBInterface.instance
      
      #load file hashes
      @mapping_hash = @db.find_value(key.mapping_key)
      @content_hash_key = key.content_key
      info_hash = @db.find_value(key.info)
      
      #init xml transformer
      @xml_transformer = Transformer::XMLTransformer.new()
      @xml_transformer.database = key.db_name
      @xml_transformer.collection = key.col_name
      @xml_transformer.mapping = @mapping_hash
      @xml_transformer.content_hash = @content_hash_key
      
      #load root key - KeyElementBuilder object
      puts @mapping_hash.inspect
      @root_key = Transformer::KeyElementBuilder.create(info_hash["root"])
      
    end
    
    #key - KeyElementBuilder object
    #key needs to be translated into ids (so use get_elem_index method before calling elem method on KeyElementBuilder object)
    def get_children(key)
      ChildrenBean.new(key, get_children_plain(key))
    end
    
    def get_children_element_keys(key)
      key_array = []
      get_children_plain(key).each { |str_key|
          if(!Transformer::KeyElementBuilder.text?(str_key))
            new_key = Transformer::KeyElementBuilder.build_from_s(str_key)
            key_array << new_key
          end
        }
      return key_array
    end
    
    def get_children_plain(key)#String Array
      values = []
      list_str = @db.get_hash_value(@content_hash_key, key)
      if(list_str == nil)
        raise StandardError, "wrong key or content hash_key, nil found instead of descendants, hash_key: #{@content_hash_key}, key: #{key}"
      end
      list_str.split('|').each { |value|
        values << value if(!value.empty?)
      }
      return values
    end
    
    def get_attributes(key)
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
      fields_only.each_with_index { |field, index| #TODO how the attributes are saved? (should be saved as ids, not names)
        attribute_hash[field] = values_only[index] #so far functioning ok
      }
      return attribute_hash
    end
    
    def get_text(key)
      get_children(key).get_text
    end
    
    def get_node(key)
      if(key.kind_of?(Transformer::KeyElementBuilder))
        return @xml_transformer.find_node(key)
      end
      return key      
    end
    
    def get_elem_index(elem_name)
      @mapping_hash[elem_name]
    end
    
  end
  
  
  class ChildrenBean
    
    attr_reader :elem_str_keys, :base_key, :elem_hash, :text_array
    
    def initialize(base_key, key_str_array)
      @base_key = base_key
      @elem_hash = Hash.new #key: elem_name, value: elem_count
      @text_array = [] #array of key_str
      @elem_str_keys = []
      
      key_str_array.each { |key_str|
        if(Transformer::KeyElementBuilder.text?(key_str))
          @text_array << key_str
        else
          @elem_str_keys << key_str
          key = Transformer::KeyElementBuilder.build_from_s(key_str)
          @elem_hash[key.elem_name] = (key.order.to_i + 1)
        end
      }
    end
    
    def get_text
      text = ""
      @text_array.each { |t|
        text << t
      }
      return text
    end
    
  end
  
  
  class KeyBean
    
    attr_reader :doc_key, :elem_key
    
    def initialize(doc_key, elem_key)
      @doc_key = doc_key
      @elem_key = elem_key
    end
    
  end
  
end