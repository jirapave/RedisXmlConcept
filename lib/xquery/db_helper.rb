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
      values = []
      list_str = @db.get_hash_value(@content_hash_key, key)
      if(list_str == nil)
        raise StandardError, "wrong key or content hash_key, nil found instead of descendants, hash_key: #{@content_hash_key}, key: #{key}"
      end
      list_str.split('|').each { |value|
        values << value if(!value.empty?)
      }
      ChildrenBean.new(key, values)
    end
    
    def get_node(key)
      @xml_transformer.find_node(key)
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
    
  end
  
  
  class KeyBean
    
    attr_reader :doc_key, :elem_key
    
    def initialize(doc_key, elem_key)
      @doc_key = doc_key
      @elem_key = elem_key
    end
    
  end
  
end