require_relative "base/database"

module XMLDBApi
  class RedDatabase < XMLDBApi::Base::Database
      # Returns the name associated with the Database instance.
      # ==== Return value
      # String representing the name of the database
      def get_name()
        raise XMLDBApi::Base::ErrorCodes::NotImplemetedError
      end
      
      # Retrieves a RedCollection instance based on the URI provided
      # in the uri parameter. The format of the URI is defined in the
      # documentation for DatabaseManager#getCollection
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
      def get_collection(uri, username, password)
        raise XMLDBApi::Base::ErrorCodes::NotImplemetedError
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
        raise XMLDBApi::Base::ErrorCodes::NotImplemetedError
      end
      
      # Returns the XML:DB API Conformance level for the implementation. Currently level 0.
      # ==== Return value
      # 0 - conformance level
      def get_conformance_level()
        raise XMLDBApi::Base::ErrorCodes::NotImplemetedError
      end
      
      # Returns the value of the property identified by name parameter
      # ==== Parameters
      # * +name+ - The name of the property to retrieve
      # ==== Return value
      # The property value or null if no property exists.
      def get_property(name)
        raise XMLDBApi::Base::ErrorCodes::NotImplemetedError
      end

      # Sets the property name to have the value provided in value
      # ==== Parameters
      # * +name+ - The name of the property to set
      # * +value+ - The value to set for the property
      def set_property(name, value)
        raise XMLDBApi::Base::ErrorCodes::NotImplemetedError
      end
  end
end