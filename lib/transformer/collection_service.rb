require_relative "key_builder"
require_relative "../red_xml_api/collection"

module Transformer
  class CollectionService
    def initialize(env_id, coll_id = false, coll_name = false)
      @env_id = env_id
      @coll_id = coll_id
      @coll_name = coll_name
      @env_info = Transformer::KeyBuilder.environment_info(@env_id)
      @certain_coll_key = Transformer::KeyBuilder.child_collections_key(@env_id, @coll_id) if @coll_id
      @certain_coll_key = Transformer::KeyBuilder.collections_key(@env_id) unless @coll_id
      #@coll_key = Transformer::KeyBuilder.child_collections_key(@env_id, @coll_id) if coll_id
      @db_interface = BaseInterface::DBInterface.instance
    end

    def get_current_collection_id()
      @coll_id
    end

    def create_collection(name)
      coll_id = @db_interface.increment_hash(@env_info, Transformer::KeyElementBuilder::ITERATOR_KEY, 1)
      result = @db_interface.add_to_hash_ne(@certain_coll_key, name, coll_id)
      raise Transformer::MappingException, "Collection with such a name already exist." unless result
      #Now we have to save parent id to hash if we are creating nested collection
      created_coll_info_key = Transformer::KeyBuilder.collection_info(@env_id, coll_id)
      #Child collection now know id of it's parent
      info = [Transformer::KeyBuilder::NAME_KEY, name]
      #Create <parent_id> only if it has any parent, environment is not a parent
      info << Transformer::KeyBuilder::PARENT_ID_KEY << @coll_id if @coll_id
      @db_interface.add_to_hash(created_coll_info_key, info, true)
      coll_id
    end

    def delete_collection(name)
      #Delete collection = delete all documents in it and than delete field in envId:collections key
      coll_id = get_collection_id(name)
      collection = RedXmlApi::Collection.new(@env_id, coll_id)
      collection.delete_all_documents
      collection.delete_all_collections
      @db_interface.delete_from_hash @certain_coll_key, name
      #We have to delete all keys of collection, e.g. <info, <documents, <collections
      del_keys = [Transformer::KeyBuilder.collection_info(@env_id, coll_id), Transformer::KeyBuilder.documents_key(@env_id, coll_id), Transformer::KeyBuilder.child_collections_key(@env_id, coll_id)]
      @db_interface.delete_keys del_keys
    end

    def delete_all_collections()
      all_names = get_all_collections_names()
      all_names.each do |name|
        delete_collection(name)
      end
    end

    def get_collection_id(name)
      coll_id = @db_interface.get_hash_value(@certain_coll_key, name)
      raise Transformer::MappingException, "Collection with such a name doesn't exist." unless coll_id
      coll_id
    end

    def get_all_collections_ids()
      ids =  @db_interface.get_all_hash_values(@certain_coll_key)
      ids ||= []
      return ids
    end

    def get_all_collections_names()
      #Remember there are fields begininf with "<" which has to be excluded
      names =  @db_interface.get_all_hash_fields(@certain_coll_key)
      names ||= []
      return names
    end
    
    # Returns id of the parent collection or nil
    def get_parent_id()
      result = nil
      if @coll_id #if coll_id is false, than collection_service is used by environment so no parent
        info = Transformer::KeyBuilder.collection_info(@env_id, @coll_id)
        result = @db_interface.get_hash_value(info, Transformer::KeyBuilder::PARENT_ID_KEY)
      end
      return result
    end
    
    # Returns name of the parent collection or nil
    def get_parent_name()
      parent_id = get_parent_id
      return nil unless parent_id
      temp_coll_service = Transformer::CollectionService.new(@env_id, parent_id)
      parent_name = temp_coll_service.get_collection_name
      return parent_name
    end
    
    # Returns name of the current collection
    def get_collection_name()
      result = nil
      if @coll_id #if coll_id is false, than collection_service is used by environment
        info = Transformer::KeyBuilder.collection_info(@env_id, @coll_id)
        result = @db_interface.get_hash_value(info, Transformer::KeyBuilder::NAME_KEY)
      end
      return result
    end

    def rename_collection(old_name, name)
      #Verify that new name isn't already in database
      result = @db_interface.hash_value_exist?(@certain_coll_key, name)
      raise Transformer::MappingException, "Collection with such a name already exist." if result
      result = @db_interface.hash_value_exist?(@certain_coll_key, old_name)
      raise Transformer::MappingException, "Cannot rename, collection #{old_name} doesn't exist." unless result

      #Delete old enevironment
      old_id = get_collection_id(old_name)

      result = @db_interface.transaction do
        @db_interface.delete_from_hash(@certain_coll_key, old_name)
        @db_interface.add_to_hash_ne(@certain_coll_key, name, old_id)
      end

      #Note: result may obtain some old return values from redis, we have to lookup at the end of result
      raise Transformer::MappingException, "Cannot delete old collection's name, rename aborted." if result[-1] != 1
      raise Transformer::MappingException, "Renaming failed." if result[-2] != 1
      true
    end

    def collection_exist?(name)
      return @db_interface.hash_value_exist?(@certain_coll_key, name)
    end
  end
end