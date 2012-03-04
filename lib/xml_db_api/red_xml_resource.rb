require_relative "modules/xml_resource"

module XMLDBApi
  class RedCollection < XMLDBApi::Modules::XMLResource

      # Returns the unique id for the parent document to this Resource
      # or null if the Resource does not have a parent document.
      # getDocumentId() is typically used with Resource
      # instances retrieved using a query. It enables accessing the parent
      # document of the Resource even if the Resource is
      # a child node of the document. If the Resource was not
      # obtained through a query then getId() and
      # getDocumentId() will return the same id.
      # ==== Return value
      # The id for the parent document of this Resource or
      # null if there is no parent document for this Resource.
      def get_document_id()
        raise XMLDBApi::Base::ErrorCodes::NotImplemetedError
      end

      # Returns the content of the Resource as a DOM Node.
      # ==== Return value
      # The XML content as a DOM Node
      def get_content_as_dom()
        raise XMLDBApi::Base::ErrorCodes::NotImplemetedError
      end

      # Sets the content of the Resource using a DOM Node as the
      # source.
      # ==== Parameters
      # * +content+ - The new content value
      # ==== Raises
      # XMLDBApi::Base::XMLDBException with expected error codes.
      # ErrorCodes.INVALID_RESOURCE if the content value provided is null.
      # ErrorCodes.WRONG_CONTENT_TYPE if the content provided in not
      # a valid DOM Node.
      def set_content_as_dom(content)
        raise XMLDBApi::Base::ErrorCodes::NotImplemetedError
      end

      # Allows you to use a ContentHandler to parse the XML data from
      # the database for use in an application.
      # ==== Parameters
      # * +handler+ - the SAX ContentHandler to use to handle the Resource content.
      # ==== Raises
      # XMLDBApi::Base::XMLDBException with expected error codes.
      # ErrorCodes.INVALID_RESOURCE if the content value provided is null.
      def get_content_as_sax(handler)
        raise XMLDBApi::Base::ErrorCodes::NotImplemetedError
      end

      # Sets the content of the Resource using a SAX
      # ContentHandler.
      # ==== Return value
      # A SAX ContentHandler that can be used to add content into the Resource.
      def set_content_as_sax()
        raise XMLDBApi::Base::ErrorCodes::NotImplemetedError
      end
      
      # Returns the RedCollection instance that this resource is
      # associated with. All resources must exist within the context of a
      # Redcollection.
      # ==== Return value
      # The RedCollection asociated with the resource
      def get_parent_collection()
        raise XMLDBApi::Base::ErrorCodes::NotImplemetedError
      end

      # Returns the unique id for this RedXMLResource or nil if the
      # RedXMLResource is anonymous. The RedXMLResource will be
      # anonymous if it is obtained as the result of a query.
      # ==== Return value
      # The id for the RedXMLResource or nil if no id exists.
      def get_id()
        raise XMLDBApi::Base::ErrorCodes::NotImplemetedError
      end

      # Returns the XMLResource type
      # ==== Return value
      # String with XMLResource type
      def get_resource_type()
        raise XMLDBApi::Base::ErrorCodes::NotImplemetedError
      end

      # Retrieves the content from the RedXMLResource, basically XML String
      # ==== Return value
      # String value with content of the XML
      def get_content()
        raise XMLDBApi::Base::ErrorCodes::NotImplemetedError
      end

      # Sets the content for this resource. The type of content that can be set
      # depends on the type of resource being used.
      # ==== Parameters
      # * +value+ - The XML content value to set for the resource as a String
      def set_content(value)
        raise XMLDBApi::Base::ErrorCodes::NotImplemetedError
      end
  end
end