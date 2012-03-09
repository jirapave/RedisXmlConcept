require_relative "key_builder"
require_relative "../red_xml_api/collection"

module Transformer
  # Class represents an abstraction layer which provides basic functionality to work with Collections. 
  # It is possible to create, delete or rename collections and much more.
  class CollectionService
    
    # Createsnew instance of CollectionService. It's functionality is heavily influenced by
    # the parameters. Using only env_id means that all operations are invoked as if environment with ID
    # env_id invoked them. On the other hand, when coll_id and coll_name are specified all operations
    # are invoked as if collection with such an ID would invoked them.
    # Remember, collections can be nested, so environment creates "root" colletions and those collections
    # can create "child" collections.
    # ==== Parameters
    # * +env_id+ - ID of the environment in which operations will be executed (unless other prameters are set)
    # * +coll_id+ - ID of the collection in which operations will be executed located in environment with ID env_id
    # * +coll_name+ - Name of the collection in which operations will be executed located in environment with ID env_id
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

    # Returns ID of the collection, which is using this instance of CollectionService
    # ==== Return value
    # String with the ID of the colletion which uses this instance of CollectionService or nil if
    # this service is used by Environment
    def get_collection_id()
      result = nil
      result = @coll_id if @coll_id
      result
    end

    # Creates new collection with a given name in a database and returns it's ID
    # ==== Parameters
    # * +name+ - Name of the collection to be created
    # ==== Return value
    # String with the ID of the created collection
    # ==== Raises
    # Transformer::MappingException - If collection with such a name already exist
    def create_child_collection(name)
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

    # Deletes collection with a given name from the database, if collection with such a name
    # does not exist method will return.
    # ==== Parameters
    # * +name+ - Name of the collection to be deleted
    def delete_child_collection(name)
      #Delete collection = delete all documents in it and than delete field in envId:collections key
      coll_id = nil
      begin
        coll_id = get_child_collection_id(name)
      rescue Transformer::MappingException => ex
        ex.message
        return
      end
      collection = RedXmlApi::Collection.new(@env_id, coll_id)
      collection.delete_all_documents
      collection.delete_all_child_collections
      @db_interface.delete_from_hash @certain_coll_key, name
      #We have to delete all keys of collection, e.g. <info, <documents, <collections
      del_keys = [Transformer::KeyBuilder.collection_info(@env_id, coll_id), Transformer::KeyBuilder.documents_key(@env_id, coll_id), Transformer::KeyBuilder.child_collections_key(@env_id, coll_id)]
      @db_interface.delete_keys del_keys
    end

    # Deletes all collections in a database.
    def delete_all_child_collections()
      all_names = get_all_child_collections_names()
      all_names.each do |name|
        delete_child_collection(name)
      end
    end

    # Returns ID for the collection specified by name.
    # ==== Parameters
    # * +name+ - Name of the collection for which the ID should be retrieved
    # ==== Return value
    # String with the ID of the collection
    # ==== Raises
    # Transformer::MappingException - If collection with such a name does not exist
    def get_child_collection_id(name)
      coll_id = @db_interface.get_hash_value(@certain_coll_key, name)
      raise Transformer::MappingException, "Collection with such a name doesn't exist." unless coll_id
      coll_id
    end

    # Returns IDs of all collections in the database
    # ==== Return value
    # Array with IDs of all collections
    def get_all_child_collections_ids()
      ids =  @db_interface.get_all_hash_values(@certain_coll_key)
      ids ||= []
      return ids
    end

    # Returns names of all collections in the database
    # ==== Return value
    # Array with names of all collections
    def get_all_child_collections_names()
      #Remember there are fields begininf with "<" which has to be excluded
      names =  @db_interface.get_all_hash_fields(@certain_coll_key)
      names ||= []
      return names
    end
    
    # Returns ID of the parent of collection which is using this instance of CollectionService
    # ==== Return value
    # String with ID of the parent collection or nil if there is no parent 
    def get_parent_id()
      result = nil
      if @coll_id #if coll_id is false, than collection_service is used by environment so no parent
        info = Transformer::KeyBuilder.collection_info(@env_id, @coll_id)
        result = @db_interface.get_hash_value(info, Transformer::KeyBuilder::PARENT_ID_KEY)
      end
      return result
    end
    
    # Returns name of the parent of collection which is using this instance of CollectionService
    # ==== Return value
    # String with name of the parent collection or nil if there is no parent 
    def get_parent_name()
      parent_id = get_parent_id
      return nil unless parent_id
      temp_coll_service = Transformer::CollectionService.new(@env_id, parent_id)
      parent_name = temp_coll_service.get_collection_name
      return parent_name
    end
    
    # Returns name of the collection which is using this instance of CollectionService
    # ==== Return value
    # String with name of the collection or nil if no collection is usin this instance of CollectionService
    def get_collection_name()
      result = nil
      if @coll_id #if coll_id is false, than collection_service is used by environment
        info = Transformer::KeyBuilder.collection_info(@env_id, @coll_id)
        result = @db_interface.get_hash_value(info, Transformer::KeyBuilder::NAME_KEY)
      end
      return result
    end

    # Rename collection = change it's name, not ID. When called from Environment root collections are searched
    # to be renamed. If Collection is using this service, than child collections are searched to be renamed.
    # ==== Parameters
    # * +old_name+ - Name of the collection which should be renamed
    # * +name+ - New name for the collection
    # ==== Raises
    # Transformer::MappingException - If collection with old_name does not exist or if there already
    # is collection with name parameter as it's name
    def rename_child_collection(old_name, name)
      #Verify that new name isn't already in database
      result = @db_interface.hash_value_exist?(@certain_coll_key, name)
      raise Transformer::MappingException, "Collection with such a name already exist." if result
      result = @db_interface.hash_value_exist?(@certain_coll_key, old_name)
      raise Transformer::MappingException, "Cannot rename, collection #{old_name} doesn't exist." unless result

      #Delete old enevironment
      old_id = get_child_collection_id(old_name)

      result = @db_interface.transaction do
        @db_interface.delete_from_hash(@certain_coll_key, old_name)
        @db_interface.add_to_hash_ne(@certain_coll_key, name, old_id)
      end

      #Note: result may obtain some old return values from redis, we have to lookup at the end of result
      raise Transformer::MappingException, "Cannot delete old collection's name, rename aborted." if result[-1] != 1
      raise Transformer::MappingException, "Renaming failed." if result[-2] != 1
      true
    end

    # Verifies if collection with a given name exist (under the certain Environment or Collection based
    # on which is using this service)
    # ==== Return value
    # True if the collection with given name exist, False otherwise
    def child_collection_exist?(name)
      return @db_interface.hash_value_exist?(@certain_coll_key, name)
    end
  end
end