require_relative "base/collection"
require_relative "modules/collection_management_service"
require_relative "../transformer/collection_service"
require_relative "../transformer/exceptions"

module XMLDBApi
  class RedCollectionManagementService < XMLDBApi::Modules::CollectionManagementService
    def initialize(db_id)
      @name = "RedCollectionManagementService"
      @version = "1.0"
      @db_id = db_id
      @collection = nil
      @coll_service = nil
    end
    
      # Creates a new RedCollection in the database. The new RedCollection will be 
      # created relative to the RedCollection from which the RedCollectionManagementService
      # was retrieved.
      # ==== Parameters
      # * +name+ - The name of the collection to create.
      # ==== Return value
      # The created RedCollection instance
      # ==== Raises
      # XMLDBApi::Base::XMLDBException with expected error codes.
      # * ErrroCodes.COLLECTION_ALREADY_EXIST If there already exist colletion with a given name
      def create_collection(name)
        begin
          @coll_service = Transformer::CollectionService.new(@db_id) unless @coll_service
          coll_id = @coll_service.create_child_collection(name)
          return XMLDBApi::RedCollection.new(@db_id, coll_id, name)
        rescue Transformer::MappingException => ex
          raise XMLDBApi::Base::XMLDBException.new(XMLDBApi::Base::ErrorCodes::COLLECTION_CLOSED), "Cannot create collection, collection with the name #{name} already exist"
        end
      end
      
      # Removes a named RedCollection from the system. The name for the RedCollection
      # to remove is relative to the RedCollection from which the CollectionManagementService
      # was retrieved.
      # ==== Parameters
      # * +name+ - The name of the collection to remove.
      def remove_collection(name)
        begin
          @coll_service.delete_child_collection(name)
        rescue Exception => ex
          raise XMLDBApi::Base::XMLDBException.new(XMLDBApi::Base::ErrorCodes::UNKNOWN_ERROR), "Delete operation failed, collection #{name} couldn't be removed"
        end
      end

      # Returns the name associated with the Service instance.
      # ==== Return value
      # The name of the object
      def get_name
        @name
      end

      # Gets the Version attribute of the Service object
      # ==== Return value
      # The version value
      def get_version()
        @version
      end

      # Sets the Collection attribute of the Service object
      # ==== Parameters
      # * +col+ - The new RedCollection value
      def set_collection(col)
        @collection = col
        @coll_service = @collection.coll_service
      end
  end
end