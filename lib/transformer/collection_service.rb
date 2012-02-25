require_relative "key_builder"

module Transformer
  class CollectionService
    def initialize(env_id)
      @env_id = env_id
      @coll_key = Transformer::KeyBuilder.collections_key(@env_id)
      @db_interface = BaseInterface::DBInterface.instance
    end
    
    def create_collection(name)
      coll_id = @db_interface.increment_hash(@coll_key, Transformer::KeyElementBuilder::ITERATOR_KEY, 1)
      result = @db_interface.add_to_hash_ne(@coll_key, name, coll_id)
      raise Transformer::MappingException, "Collection with such a name already exist." unless result
      coll_id
    end
    
    def delete_collection(name)
      
    end
    
    def delete_all_collections()
      
    end
    
    def get_collection_id(name)
      coll_id = @db_interface.get_hash_value(@coll_key, name)
      raise Transformer::MappingException, "Collection with such a name doesn't exist." unless coll_id
      coll_id
    end
    
    def get_all_collections_ids()
      return @db_interface.get_all_hash_values(@coll_key)
    end
    
    def rename_collection(old_name, name)
      
    end
  end
end