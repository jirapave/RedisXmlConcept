require_relative "key_element_builder"
require_relative "mapping_service"

module Transformer
  class KeyBuilder
    
    SEPARATOR = ":"
    ITERATOR_KEY = "<iterator>"
    
    attr_reader :environment_key, :collection_key, :document_key
    attr_accessor :mapping_service
    
    def initialize(env_id, coll_id, doc_id)
        @env_id = env_id
        @coll_id = coll_id
        @doc_id = doc_id
      @environment_key = @env_id
      @collection_key = "#{@environment_key}#{SEPARATOR}#{@coll_id}"
      @document_key = "#{@collection_key}#{SEPARATOR}#{@doc_id}"
    end
    
    def self.environments_key()#:String
      "environments"
    end
    
    def self.collections_key(env_id)#:String
      "#{env_id}#{SEPARATOR}collections"
    end
    
    def self.documents_key(env_id, coll_id)#:String
      value = "#{env_id}#{SEPARATOR}#{coll_id}#{SEPARATOR}documents"
      value
    end
    
    def self.build_from_s(key_str)#:Key
      key_split = key_str.split(SEPARATOR)
      if(key_split.length < 3)
        raise NotEnoughParametersError, #{key_str} cannot be parsed to Key. Simply said: not enough '#{SEPARATOR}' delimiters."
      end
      return new(key_split[0], key_split[1], key_split[2])
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
    def root(root_id):KeyElementBuilder
      KeyElementBuilder.new(self, root_id)
    end
    
    def to_s()#:String
      @document_key
    end
    
    class NotEnoughParametersError < StandardError
    end
    
  end
end