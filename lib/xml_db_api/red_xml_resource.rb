require_relative "modules/xml_resource"
require_relative "../xml/dom_sax_service"
require_relative "../xml/sax_dom_creator"
require "rubygems"
require "nokogiri"

module XMLDBApi
  class RedXmlResource < XMLDBApi::Modules::XMLResource
      TYPE = "XMLResource"
      
      attr_reader :document, :doc_id, :db_id, :coll_id, :doc_name
      
      def initialize(db_id, coll_id, doc_name, doc_id, document)
        @doc_id = doc_id
        @doc_name = doc_name
        @coll_id = coll_id
        @db_id = db_id
        @coll_service = Transformer::CollectionService.new(@db_id, @coll_id)
        @doc_service = Transformer::DocumentService.new(@db_id, @coll_id)
        @document = document
        @empty = false
        @empty = true if @document == nil
      end
      
      # Refresh state of the resource, useful when we have empty resource, should't be used by users
      # ==== Parameters
      # * +doc_id+ - Real Id (not name) of the resource
      # * +document+ - Nokogiri::XML::Document instance
      def refresh_state(doc_id, document)
        @doc_id = doc_id
        @document = document
        @empty = false
        @empty = true if @document == nil or doc_id == nil
      end

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
        return @doc_name #Remember, name = id in xmldb API
      end

      # Returns the content of the Resource as a DOM Node.
      # ==== Return value
      # The XML content as a DOM Node (Nokogiri::XML::Document)
      def get_content_as_dom()
        return @document
      end

      # Sets the content of the Resource using a DOM Node as the
      # source.
      # ==== Parameters
      # * +content+ - The new content value of type Nokogiri::XML::Document or
      #               Nokogiri::XML::Node. If Node is used, than it is considered
      #               to be a root of new document
      # ==== Raises
      # XMLDBApi::Base::XMLDBException with expected error codes.
      # ErrorCodes.INVALID_RESOURCE if the content value provided is null.
      # ErrorCodes.WRONG_CONTENT_TYPE if the content provided in not
      # a valid DOM Node = Nokogiri::XML::Document or Nokogiri::XML::Node.
      def set_content_as_dom(content)
        raise XMLDBApi::Base::XMLDBException.new(XMLDBApi::Base::ErrorCodes::INVALID_RESOURCE), "Content is nil" if content == nil
        
        #Variable document should always contain document, not just plain element
        
        if content.respond_to?(:root)
          @document = content
          @empty = false
          return
        end
        
        if content.respond_to?(:element_node?)
          if content.element_node?
            builder = Nokogiri::XML::Builder.new
            @document = builder.doc
            @document.root = content
            @empty = false
            return
          end
        end
        raise XMLDBApi::Base::XMLDBException.new(XMLDBApi::Base::ErrorCodes::WRONG_CONTENT_TYPE), "Given parameter is not a valid XML Node or Document"
      end

      # Allows you to use a Nokogiri::XML::SAX::Document to parse the XML data from
      # the database for use in an application.
      # ==== Parameters
      # * +handler+ - the SAX content handler to use to handle the Resource content, it has to extend
      #               Nokogiri::XML::SAX::Document
      # ==== Raises
      # XMLDBApi::Base::XMLDBException with expected error codes.
      # ErrorCodes.INVALID_RESOURCE if the content value provided is null.
      def get_content_as_sax(handler)
        return if empty?
        #dom_sax_service = XML::DomSaxService.new 
        #dom_sax_service.generate_sax_from_dom(handler, @document)
        parser = Nokogiri::XML::SAX::Parser.new(handler)
        parser.parse("#{@document}")
      end

      # Sets the content of the Resource using a SAX
      # ContentHandler.
      # ==== Return value
      # A SAX ContentHandler (Nokogiri::XML::SAX::Document) that can be used to add content 
      # into the Resource. 
      def set_content_as_sax()
        return XML::SaxDomCreator.new(self)
      end
      
      # Returns the RedCollection instance that this resource is
      # associated with. All resources must exist within the context of a
      # RedCollection.
      # ==== Return value
      # The RedCollection asociated with the resource
      def get_parent_collection()
        return XMLDBApi::RedCollection.new(@db_id, @coll_service.get_collection_id, @coll_service.get_collection_name)
      end

      # Returns the unique id for this RedXMLResource or nil if the
      # RedXMLResource is anonymous. The RedXMLResource will be
      # anonymous if it is obtained as the result of a query.
      # ==== Return value
      # The id for the RedXMLResource or nil if no id exists.
      def get_id()
        return @id
      end

      # Returns the XMLResource type
      # ==== Return value
      # String with XMLResource type
      def get_resource_type()
        return RedXmlResource::TYPE
      end

      # Retrieves the content from the RedXMLResource, basically XML String
      # ==== Return value
      # String value with content of the XML
      def get_content()
        return "#{@document}"
      end

      # Sets the content for this resource. The type of content that can be set
      # depends on the type of resource being used.
      # ==== Parameters
      # * +value+ - The XML content value to set for the resource as a String
      def set_content(value)
        @document = Nokogiri::XML(value)
        @empty = false if @document #Resource can now be stored in database
      end
      
      # Check if the RedXmlResource is empty = cannot be stored in database because it has no
      # content
      # ==== Return value
      # True if this RedXmlResource instance is empty, False otherwise
      def empty?()
        return @empty
      end
  end
end