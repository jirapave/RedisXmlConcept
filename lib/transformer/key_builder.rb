require_relative "key_element_builder"
require_relative "mapping_helper"

module Transformer
  class KeyBuilder

    private_class_method :new
    
    SEPARATOR = ":"
    ITERATOR_KEY = "<iterator>"
    
    attr_reader :environment_key, :collection_key, :document_key
    
    def initialize(env_name, coll_name, doc_name, map_names = true)
      #TODO There should be some error if no mapping is found
      if (map_names)
        @mapping = Transformer::MappingHelper.map_env_coll_doc(env_name, coll_name, doc_name)
        @mapping_service = Transformer::MappingHelper.create(self)
        @env_id = @mapping["env"]
        @coll_id = @mapping["coll"]
        @doc_id = @mapping["doc"]
      else
        @env_id = env_name
        @coll_id = coll_name
        @doc_id = doc_name
      end
      @environment_key = @env_id
      @collection_key = "#{@environment_key}#{SEPARATOR}#{@coll_id}"
      @document_key = "#{@collection_key}#{SEPARATOR}#{@doc_id}"
    end
    
    #Creates new Key with required parameters
    def self.create(env_name, coll_name, doc_name)#:Key
      return new(env_name, coll_name, doc_name)
    end
    
    def self.environments_key()#:String
      "environments"
    end
    
    def self.collections_key(env_name, map_names = true)#:String
      if map_names
        id_env = Transformer::MappingHelper.map_env(env_name)
      else
        id_env = env_name
      end
      "#{id_env}#{SEPARATOR}collections"
    end
    
    def self.documents_key(env_name, coll_name, map_names = true)#:String
      if map_names
        id_map = Transformer::MappingHelper.map_env_coll(env_name, coll_name)
        value = "#{id_map["env"]}#{SEPARATOR}#{id_map["coll"]}#{SEPARATOR}documents"
      else
        value = "#{env_name}#{SEPARATOR}#{coll_name}#{SEPARATOR}documents"
      end
      value
    end
    
    def self.build_from_s(key_str)#:Key
      key_split = key_str.split(SEPARATOR)
      if(key_split.length < 3)
        raise NotEnoughParametersError, #{key_str} cannot be parsed to Key. Simply said: not enough '#{SEPARATOR}' delimiters."
      end
      return new(key_split[0], key_split[1], key_split[2], false)
    end
      
    #Deprecated
    #Because of mapping, we need to know env, coll and doc ids... = we need KeyBuilder instance
    #def self.root(doc_key, root_name)
    #  KeyElementBuilder.create(doc_key, root_name)
    #end
    
    def info()#:String
      "#{@document_key}<info"
    end
    
    def elem_mapping_key()#:String
      "#{@document_key}<emapping"
    end
    
    def attr_mapping_key()#:String
      "#{@document_key}<amapping"
    end
    
    def content_key()#:String
      "#{@document_key}<content"
    end

    # root returns KeyElementBuilder, which require root element to initialize
    # that there is possible to create element_keys and so on    
    def root(root_name, map_names = true):KeyElementBuilder
      root_name = @mapping_service.unmap_elem_name(root_name) unless map_names
      KeyElementBuilder.create(self, root_name)
    end
    
    def to_s()#:String
      @document_key
    end
    
    class NotEnoughParametersError < StandardError
    end
    
  end
end