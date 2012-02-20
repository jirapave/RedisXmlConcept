require_relative "key_builder"

module Trannsformer
  class CollectionService
    def initialize(env_name)
      @env_name = env_name
      @coll_key = Transformer::KeyBuilder.collections_key(@env_name)
      @db_interface = BaseInterface::DBInterface.instance
    end
    
    def create_collection(name)
      coll_id = @db_interface.increment_hash(@coll_key, Transformer::KeyElementBuilder::ITERATOR_KEY, 1)
      result = @db_interface.add_to_hash_ne(@coll_key, name, coll_id)
      raise MappingException, "Collection with such a name already exist." unless result
      result
    end
    
    def delete_collection(name)
      
    end
    
    def delete_all_collections()
      
    end
    
    def get_collection()
      
    end
    
    def get_all_collections()
      
    end
    
    class MappingException < StandardError
      def message
        "Error has occured during mapping name to id"
      end
    end
  end
end