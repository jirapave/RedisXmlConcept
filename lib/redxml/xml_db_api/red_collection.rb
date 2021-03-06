require_relative "base/collection"
require_relative "red_collection_management_service"
require_relative "../transformer/collection_service"
require_relative "../transformer/document_service"

module XMLDBApi
  # This class represents an implementation of Colletion and is used as a main point to going
  # through the logical structure of content of the database. Basically collection represents
  # folder.
  class RedCollection < XMLDBApi::Base::Collection

    # CollectionService getter to be used by RedCollectionManagementService
    attr_reader :coll_service
    # Getter fot he id of the database where the collection is located
    attr_reader :db_id
    # Getter fot he id of the collection
    attr_reader :coll_id
    # Geter fot the name of the collection
    attr_reader  :coll_name
    def initialize(db_id, coll_id, coll_name)
      @coll_name = coll_name
      @coll_id = coll_id
      @db_id = db_id
      @coll_service = Transformer::CollectionService.new(@db_id, @coll_id)
      @doc_service = Transformer::DocumentService.new(@db_id, @coll_id)
      @services = []
      @properties = {}
      @closed = false

      @coll_man_service = XMLDBApi::RedCollectionManagementService.new(@db_id)
      @coll_man_service.set_collection(self)
      @services << @coll_man_service
    end

    # Returns the name associated with the Collection instance.
    # ==== Return value
    # String representing the name of the collection
    def get_name()
      return @coll_name
    end

    # Provides an Array of all services known to the collection. If no services
    # are known an empty Array is returned.
    # ==== Return value
    # An array of registered Service implementations.
    # ==== Raises
    # XMLDBApi::Base::XMLDBException with expected error codes.
    # ErrorCodes.COLLECTION_CLOSED if the close
    # method has been called on the RedCollection
    def get_services()
      unless is_open?
        raise XMLDBApi::Base::XMLDBException.new(XMLDBApi::Base::ErrorCodes::COLLECTION_CLOSED), "Cannot perform action, collection is closed"
      end
      return @services
    end

    # Returns a Service instance for the requested service name and version. If
    # 0 Service exists for those parameters a nil value is returned.
    # ==== Parameters
    # * +name+ - Name of the service to be retrieved
    # * +version+ - Version of the service to be retrieved
    # ==== Return value
    # An array of registered Service implementations.
    # ==== Raises
    # XMLDBApi::Base::XMLDBException with expected error codes.
    # ErrorCodes.COLLECTION_CLOSED if the close
    # method has been called on the RedCollection
    def get_service(name, version)
      unless is_open?
        raise XMLDBApi::Base::XMLDBException.new(XMLDBApi::Base::ErrorCodes::COLLECTION_CLOSED), "Cannot perform action, collection is closed"
      end
      result = nil
      @services.each do |service|
        result = service if service.get_name == name and service.get_version == version
      end
      return result
    end

    # Returns the parent collection for this collection or nil if no parent
    # collection exists.
    # ==== Return value
    # XMLDBApi::RedCollection instance or nil
    # ==== Raises
    # XMLDBApi::Base::XMLDBException with expected error codes.
    # ErrorCodes.COLLECTION_CLOSED if the close
    # method has been called on the RedCollection
    def get_parent_collection
      unless is_open?
        raise XMLDBApi::Base::XMLDBException.new(XMLDBApi::Base::ErrorCodes::COLLECTION_CLOSED), "Cannot perform action, collection is closed"
      end

      parent_id = @coll_service.get_parent_id
      parent_name = @coll_service.get_parent_name
      return nil if parent_id == nil or parent_name == nil
      return XMLDBApi::RedCollection.new(@db_id, parent_id, parent_name)
    end

    # Returns the number of child collections under this
    # Collection or 0 if no child collections exist.
    # ==== Return value
    # The number of child collections
    # ==== Raises
    # XMLDBApi::Base::XMLDBException with expected error codes.
    # ErrorCodes.COLLECTION_CLOSED if the close
    # method has been called on the RedCollection
    def get_child_collection_count()
      unless is_open?
        raise XMLDBApi::Base::XMLDBException.new(XMLDBApi::Base::ErrorCodes::COLLECTION_CLOSED), "Cannot perform action, collection is closed"
      end

      result = @coll_service.get_all_child_collections_names
      return result.length if result
      return 0
    end

    # Returns a list of collection names naming all child collections
    # of the current collection. If no child collections exist an empty list is
    # returned.
    # ==== Return value
    # Array containing collection names for all child collections.
    # ==== Raises
    # XMLDBApi::Base::XMLDBException with expected error codes.
    # ErrorCodes.COLLECTION_CLOSED if the close
    # method has been called on the RedCollection
    def list_child_collections()
      unless is_open?
        raise XMLDBApi::Base::XMLDBException.new(XMLDBApi::Base::ErrorCodes::COLLECTION_CLOSED), "Cannot perform action, collection is closed"
      end

      return @coll_service.get_all_child_collections_names
    end

    # Returns XMLDBApi::RedCollection instance for the requested child collection
    # if it exists.
    # ==== Parameters
    # * +name+ - Name of the child collection to retrieve
    # ==== Return value
    # The requested child collection or nil if it couldn't be found.
    # ==== Raises
    # XMLDBApi::Base::XMLDBException with expected error codes.
    # ErrorCodes.COLLECTION_CLOSED if the close
    # method has been called on the RedCollection
    def get_child_collection(name)
      unless is_open?
        raise XMLDBApi::Base::XMLDBException.new(XMLDBApi::Base::ErrorCodes::COLLECTION_CLOSED), "Cannot perform action, collection is closed"
      end

      begin
        id = @coll_service.get_child_collection_id(name)
        return XMLDBApi::RedCollection.new(@db_id, id, name)
      rescue Transformer::MappingException => ex
        return nil
      end
    end

    # Returns the number of resources currently stored in this collection or 0
    # if the collection is empty.
    # ==== Return value
    # The number of resource in the collection.
    # ==== Raises
    # XMLDBApi::Base::XMLDBException with expected error codes.
    # ErrorCodes.COLLECTION_CLOSED if the close
    # method has been called on the RedCollection
    def get_resource_count()
      unless is_open?
        raise XMLDBApi::Base::XMLDBException.new(XMLDBApi::Base::ErrorCodes::COLLECTION_CLOSED), "Cannot perform action, collection is closed"
      end

      count = @doc_service.get_all_documents_names.length
      return count
    end

    # Returns a list of the ids for all resources stored in the collection.
    # ==== Return value
    # String Array containing the names for all Resources in the collection.
    # ==== Raises
    # XMLDBApi::Base::XMLDBException with expected error codes.
    # ErrorCodes.COLLECTION_CLOSED if the close
    # method has been called on the RedCollection
    def list_resources()
      unless is_open?
        raise XMLDBApi::Base::XMLDBException.new(XMLDBApi::Base::ErrorCodes::COLLECTION_CLOSED), "Cannot perform action, collection is closed"
      end

      return @doc_service.get_all_documents_names
    end

    # Creates a new empty Resource with the provided id.
    # The type of Resource returned is determined by the type
    # parameter. Only RedXMLResource is supported.
    # The id provided must be unique within the scope of the
    # collection. If id is nil or its value is empty then an id
    # is generated by calling createId. The Resource created is not
    # stored to the database until storeResource is called.
    # ==== Parameters
    # * +id+ - The unique id to associate with the created RedXMLResource
    # * +type+ - The Resource type to create
    # ==== Return value
    # An empty RedXMLResource instance
    # ==== Raises
    # XMLDBApi::Base::XMLDBException with expected error codes.
    # ErrorCodes.UNKNOWN_RESOURCE_TYPE if the type
    # parameter is not a known Resource type.
    # ErrorCodes.COLLECTION_CLOSED if the close
    # method has been called on the RedCollection
    def create_resource(id, type)
      unless is_open?
        raise XMLDBApi::Base::XMLDBException.new(XMLDBApi::Base::ErrorCodes::COLLECTION_CLOSED), "Cannot perform action, collection is closed"
      end

      if @doc_service.document_exist?(id)
        raise XMLDBApi::Base::XMLDBException.new(XMLDBApi::Base::ErrorCodes::RESOURCE_ID_ALREADY_EXIST), "Cannot perform action, resource with such a id already exist, id: #{id}"
      end

      if type != XMLDBApi::RedXmlResource::TYPE
        raise XMLDBApi::Base::XMLDBException.new(XMLDBApi::Base::ErrorCodes::UNKNOWN_RESOURCE_TYPE), "Cannot perform action, only XMLResource type is supported, type: #{type}"
      end

      id = create_id if id == nil or id == ""
      real_id = @doc_service.get_possible_id
      return XMLDBApi::RedXmlResource.new(@db_id, @coll_id, id, real_id, nil, RedXmlResource::STATE_EMPTY) #nil will create empty resource
    end

    # Removes the RedXMLResource from the database.
    # ==== Parameters
    # * +res+ - The RedXMLResource to remove
    # ==== Raises
    # XMLDBApi::Base::XMLDBException with expected error codes.
    # ErrorCodes.INVALID_RESOURCE if the Resource is not valid.
    # ErrorCodes.NO_SUCH_RESOURCE if the Resource is not known
    # to this Collection
    # ErrorCodes.COLLECTION_CLOSED if the close
    # method has been called on the RedCollection
    def remove_resource(res)
      unless is_open?
        raise XMLDBApi::Base::XMLDBException.new(XMLDBApi::Base::ErrorCodes::COLLECTION_CLOSED), "Cannot perform action, collection is closed"
      end
      return if res.empty? #Empty resource is not in database
      name = res.get_document_id
      raise XMLDBApi::Base::XMLDBException.new(XMLDBApi::Base::ErrorCodes::INVALID_RESOURCE), "Resource #{name} is not valid, id does not exist" unless name
      begin
        @doc_service.delete_document(name)
      rescue Transformer::MappingException => ex
        raise XMLDBApi::Base::XMLDBException.new(XMLDBApi::Base::ErrorCodes::NO_SUCH_RESOURCE), "Resource #{name} cannot be found"
      end
    end

    # Stores the provided RedXMLResource into the database. If the resource does not
    # already exist it will be created. If it does already exist it will be
    # updated.
    # ==== Parameters
    # * +res+ - The RedXMLResource to store in the database
    # ==== Raises
    # XMLDBApi::Base::XMLDBException with expected error codes.
    # ErrorCodes.INVALID_RESOURCE if the Resource is not valid (empty or has invalid type)
    # ErrorCodes.COLLECTION_CLOSED if the close
    # method has been called on the RedCollection
    def store_resource(res)
      unless is_open?
        raise XMLDBApi::Base::XMLDBException.new(XMLDBApi::Base::ErrorCodes::COLLECTION_CLOSED), "Cannot perform action, collection is closed"
      end
      if !res.respond_to?(:get_content_as_sax) or res.empty?
        raise XMLDBApi::Base::XMLDBException.new(XMLDBApi::Base::ErrorCodes::INVALID_RESOURCE), "Resource must be of type XMLResource and not be empty"
      end
      
      @doc_service.delete_document(res.get_document_id)
      begin
        @doc_service.save_resource(res)
        res.state = XMLDBApi::RedXmlResource::STATE_LOADED
      rescue Transformer::MappingException => ex
        puts ex.message
        puts "This should not happen until conccurency will be implemented"
      end
    end

    # Retrieves a RedXMLResource from the database. If the RedXMLResource
    # could not be located a nil value will be returned.
    # ==== Parameters
    # * +id+ - The Unique id for the requested resource
    # ==== Return value
    # The retrieved RedXMLResource instance
    # ==== Raises
    # XMLDBApi::Base::XMLDBException with expected error codes.
    # ErrorCodes.COLLECTION_CLOSED if the close
    # method has been called on the RedCollection
    def get_resource(id)
      unless is_open?
        raise XMLDBApi::Base::XMLDBException.new(XMLDBApi::Base::ErrorCodes::COLLECTION_CLOSED), "Cannot perform action, collection is closed"
      end

      begin
        return @doc_service.get_resource(id)
      rescue Transformer::MappingException => ex
        puts ex.message
        return nil
      end
    end

    # Creates a new unique ID within the context of the RedCollection
    # ==== Return value
    # The created ID as a String
    # ==== Raises
    # XMLDBApi::Base::XMLDBException with expected error codes.
    # ErrorCodes.COLLECTION_CLOSED if the close
    # method has been called on the RedCollection
    def create_id()
      unless is_open?
        raise XMLDBApi::Base::XMLDBException.new(XMLDBApi::Base::ErrorCodes::COLLECTION_CLOSED), "Cannot perform action, collection is closed"
      end
      
      names = @doc_service.get_all_documents_names
      not_found = true
      id = nil
      while not_found
        id = generate_id()
        unique = true
        names.each do |name|
          if name == id
            unique = false
            break;
          end
        end
        not_found = false if unique
      end
      
      return id
    end

    # Returns true if the RedCollection is open false otherwise.
    # Calling the close method on RedCollection will result in is_open?
    # returning false. It is not safe to use RedCollection instances
    # that have been closed.
    # ==== Return value
    # True if the RedCollection is open, false otherwise.
    def is_open?()
      return !@closed
    end

    # Releases all resources consumed by the Collection.
    # The close method must always be called when use of
    # a RedCollection is complete. It is not safe to use a\
    # RedCollection after the close method has been called.
    def close()
      @closed = true
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
    
    # Creates a new RedCollection in the database which will be child of this collection
    # ==== Parameters
    # * +name+ - The name of the collection to create.
    # ==== Return value
    # The created RedCollection instance
    # ==== Raises
    # XMLDBApi::Base::XMLDBException with expected error codes.
    # * ErrroCodes.COLLECTION_ALREADY_EXIST If there already exist child colletion with a given name
    def create_child_collection(name)
      return @coll_man_service.create_collection(name)
    end
    
    # Removes specified child RedCollection from the database
    # ==== Parameters
    # * +name+ - The name of the child collection to remove.
    def remove_child_collection(name)
      return @coll_man_service.remove_collection(name)
    end

    private
    def generate_id(size = 16)#:nodoc:
      charset = %w{ 2 3 4 6 7 9 A C D E F G H J K M N P Q R T V W X Y Z}
      (0...size).map{ charset.to_a[rand(charset.size)] }.join
    end
  end
end