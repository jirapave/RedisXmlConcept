require_relative "key_builder"
require_relative "../red_xml_api/collection"

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
      #Delete collection = delete all documents in it and than delete field in envId:collections key
      coll_id = get_collection_id(name)
      RedXmlApi::Collection.new(@env_id, coll_id).delete_all_documents
      @db_interface.delete_from_hash @coll_key, name
    end
    
    def delete_all_collections()
      all_names = get_all_collections_names()
      all_names.each do |name|
        delete_collection(name)
      end
    end
    
    def get_collection_id(name)
      coll_id = @db_interface.get_hash_value(@coll_key, name)
      raise Transformer::MappingException, "Collection with such a name doesn't exist." unless coll_id
      coll_id
    end
    
    def get_all_collections_ids()
      #Remember there is a field <iterator> which we have to exclude
      iter_id = @db_interface.get_hash_value(@coll_key, Transformer::KeyBuilder::ITERATOR_KEY)
      #We have to exclude first occurence of iter_id
      result = @db_interface.get_all_hash_values(@coll_key)
      if iter_id
        ind = nil
        result.each_with_index do |id, index|
          if id == iter_id
            ind = index
            break
          end
        end
        result.delete_at(ind) if ind
      end
      return result
    end
    
    def get_all_collections_names()
      names =  @db_interface.get_all_hash_fields(@coll_key)
      ind = nil
      names.each_with_index do |name, index|
        if name == Transformer::KeyBuilder::ITERATOR_KEY
          ind = index
          break
        end
      end
      names.delete_at(ind) if ind
      return names
    end
    
    def rename_collection(old_name, name)
      #Verify that new name isn't already in database
      result = @db_interface.hash_value_exist?(@coll_key, name)
      raise Transformer::MappingException, "Collection with such a name already exist." if result
      result = @db_interface.hash_value_exist?(@coll_key, old_name)
      raise Transformer::MappingException, "Cannot rename, collection #{old_name} doesn't exist." unless result
      
      #Delete old enevironment
      old_id = get_collection_id(old_name)
      
      result = @db_interface.transaction do
        @db_interface.delete_from_hash(@coll_key, old_name)
        @db_interface.add_to_hash_ne(@coll_key, name, old_id)
      end
      
      #Note: result may obtain some old return values from redis, we have to lookup at the end of result
      raise Transformer::MappingException, "Cannot delete old collection's name, rename aborted." if result[-1] != 1
      raise Transformer::MappingException, "Renaming failed." if result[-2] != 1
      true
    end
    
    def collection_exist?(name)
      return @db_interface.hash_value_exist?(@coll_key, name)
    end
  end
end