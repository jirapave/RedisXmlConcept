require_relative "base/database"
require_relative "../transformer/environment_service"
require_relative "../transformer/collection_service"
require_relative "red_collection"
require_relative "red_collection_management_service"

module XMLDBApi
  class RedDatabase < XMLDBApi::Base::Database
    
    def initialize(name)
      @name = name
      @env_service = Transformer::EnvironmentService.new
      @db_id = nil
      @db_id = @env_service.create_environment(@name) unless @env_service.environment_exist?(@name)
      @db_id = @env_service.get_environment_id(@name) unless @db_id
      @properties = {}
    end
    
      # Returns the name associated with the Database instance.
      # ==== Return value
      # String representing the name of the database
      def get_name()
        return @name
      end
      
      # Retrieves a RedCollection instance based on the URI provided
      # in the uri parameter. The format of the URI is defined in the
      # documentation for DatabaseManager#get_collection
      # ==== Parameters
      # * +uri+ - String with the URI to use to locate the collection.
      # * +username+ - String with the password to use for authentication to the database or 
      #                null if the database does not support authentication
      # * +password+ - Valid key string ending with a text element
      # ==== Return value
      # A RedCollection instance for the requested collection or
      # nil if the collection could not be found.
      # ==== Raises
      # XMLDBApi::Base::XMLDBException with expected error codes.
      # * ErrroCodes.INVALID_URI If the URI is not in a valid format.
      # * ErrroCodes.PERMISSION_DENIED If the username
      #     and password were not accepted by the database.
      def get_collection(uri, username = false, password = false)
        #Now we have uri in format path/to/collection we have to parse collections one by one because
        #of mapping to id
        collections = uri.split("/")
        coll_service = Transformer::CollectionService.new(@db_id)
        coll_name = ""
        coll_id = ""
        collections.each do |name|
          begin
            coll_id = coll_service.get_child_collection_id(name)
            coll_name = name
            coll_service = Transformer::CollectionService.new(@db_id, coll_id)
          rescue Transformer::MappingException => ex
            raise XMLDBApi::Base::XMLDBException.new(XMLDBApi::Base::ErrorCodes::INVALID_URI), "URI is not valid, wrong path, collection #{name} does not exist"
          end
        end
        
        #No we have successfully walked though a path of collection and have the last one's id and name
        return XMLDBApi::RedCollection.new(@db_id, coll_id, coll_name)
      end

      # acceptsURI? determines whether this Database implementation
      # can handle the URI. It should return true
      # if the Database instance knows how to handle the URI and false otherwise.
      # ==== Parameters
      # * +uri+ - String with the URI to to check for
      # ==== Return value
      # True if the URI can be handled, false otherwise.
      # ==== Raises
      # XMLDBApi::Base::XMLDBException with expected error codes.
      # * ErrroCodes.INVALID_URI If the URI is not in a valid format.
      def accepts_uri?(uri)
        parsed_uri = XMLDBApi::DatabaseManager.strip_URI(uri)
        return true if @name == parsed_uri["db_name"]
        return false
      end
      
      # Returns the XML:DB API Conformance level for the implementation. Currently level 0.
      # ==== Return value
      # 0 - conformance level
      def get_conformance_level()
        return 0
      end
      
      # Returns the value of the property identified by name parameter
      # ==== Parameters
      # * +name+ - The name of the property to retrieve
      # ==== Return value
      # The property value or null if no property exists.
      def get_property(name)
        return @properties[name]
      end

      # Sets the property name to have the value provided in value
      # ==== Parameters
      # * +name+ - The name of the property to set
      # * +value+ - The value to set for the property
      def set_property(name, value)
        @properties[name] = value
      end
      
      # Returns the RedCollectionManagementService instance
      # ==== Return value
      # RedCollectionManagementService instance
      def get_collection_management_service()
        return XMLDBApi::RedCollectionManagementService.new(@db_id)
      end
  end
end