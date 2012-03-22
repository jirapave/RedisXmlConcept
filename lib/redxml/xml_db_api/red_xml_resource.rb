require_relative "modules/xml_resource"
require_relative "../xml/sax_dom_creator"
require_relative "../transformer/collection_service"
require_relative "../transformer/document_service"
require_relative "../xml/sax_dom_creator"
require_relative "red_collection"
require "rubygems"
require "nokogiri"

module XMLDBApi
  # This class represents implementation of XMLResource and is used as a base logical unit
  # of data in the database. Manipulation with content is possible using both DOM and SAX.
  class RedXmlResource < XMLDBApi::Modules::XMLResource
    # Refers to type of this Resource
    TYPE = "XMLResource"
    # Used to represent XMLResource which is empty
    STATE_EMPTY = "empty"
    # Used to represent XMLResource which has content stored in database but not yet load
    # it into memory
    STATE_LAZY = "lazy"
    # Used to represent XMLResource which has it's content in memory = no database connection
    # resuired
    STATE_LOADED = "loaded"

    attr_reader :document, :doc_id, :db_id, :coll_id, :doc_name
    # Creates new instance of RedXmlResource. All parameters are required except document. When document
    # is not specified empty resource will be returned
    def initialize(db_id, coll_id, doc_name, doc_id, document = nil, state = RedXmlResource::STATE_EMPTY)
      @doc_id = doc_id
      @doc_name = doc_name
      @coll_id = coll_id
      @db_id = db_id
      @coll_service = Transformer::CollectionService.new(@db_id, @coll_id)
      @doc_service = Transformer::DocumentService.new(@db_id, @coll_id)
      @document = document
      @state = state

      @features = get_features()
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

    # Returns current setting of a SAX feature that will be used when this XMLResource
    # is used to produce SAX events (through the get_content_as_sax() method)
    # ==== Parameters
    # * +feature+ - Feature name. Standard SAX feature names are documented
    #               at http://sax.sourceforge.net/
    # ==== Retun value
    # True if the feature is set, false otherwise.
    def get_sax_feature(feature)
      return @features[feature]
    end

    # Returns the content of the Resource as a DOM Node.
    # ==== Return value
    # The XML content as a DOM Node (Nokogiri::XML::Document)
    def get_content_as_dom()
      if @state == RedXmlResource::STATE_LAZY
        @document = @doc_service.find_document(@doc_name)
        @state = RedXmlResource::STATE_LOADED
      end
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
      @state = RedXmlResource::STATE_LOADED
      return
      end

      if content.respond_to?(:element_node?)
        if content.element_node?
          builder = Nokogiri::XML::Builder.new
        @document = builder.doc
        @document.root = content
        @state = RedXmlResource::STATE_LOADED
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
      case @state
      when RedXmlResource::STATE_EMPTY
        return
      when RedXmlResource::STATE_LAZY
        # We are generating events directly from database so we dont have to load the document
        # into memory
        @doc_service.generate_sax_events(@doc_name, handler)
      when RedXmlResource::STATE_LOADED
        parser = Nokogiri::XML::SAX::Parser.new(handler)
        parser.parse("#{@document}")
      end
    end

    # Sets the content of the Resource using a SAX
    # ContentHandler.
    # ==== Return value
    # A SAX ContentHandler (Nokogiri::XML::SAX::Document) that can be used to add content
    # into the Resource.
    def set_content_as_sax()
      # We can't use this handler to create database content because XMLDB:API specifies
      # that the only way how to store content into databse is via store_resource method
      # so we hav to create DOM in memory
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
      return @doc_name
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
      if @state == RedXmlResource::STATE_LAZY
        @document = @doc_service.find_document(@doc_name)
        @state = RedXmlResource::STATE_LOADED
      end
      return "#{@document}"
    end

    # Sets the content for this resource. The type of content that can be set
    # depends on the type of resource being used.
    # ==== Parameters
    # * +value+ - The XML content value to set for the resource as a String
    def set_content(value)
      @document = Nokogiri::XML(value)
      @state = RedXmlResource::STATE_LOADED if @document #Resource can now be stored in database
    end

    # Check if the RedXmlResource is empty = cannot be stored in database because it has no
    # content
    # ==== Return value
    # True if this RedXmlResource instance is empty, False otherwise
    def empty?()
      return true if @state == RedXmlResource::STATE_EMPTY
      return false
    end

    # Crates new KeyBuilder based on content of this XMLResource
    # ==== Return value
    # KeyBuilder instance
    def key_builder()
      Transformer::KeyBuilder.new(@db_id, @coll_id, @doc_id)
    end

    private

    # Returns all features which SAX parser has
    def get_features()#:nodoc:
      # These features are more or less accurate. Many values couldn't be verified because
      # they are used in context of Java programming language a sometimes Nokogiri just
      # dont't provide any information on the feature

      features = {
        "external-general-entities" => false,
        "external-parameter-entities" => false,
        "is-standalone" => false, #Zjistit jak ziskat z dokumentu standalone
        "lexical-handler/parameter-entities" => false,
        "namespaces" => true,
        "namespace-prefixes" => true,
        "resolve-dtd-uris" => false,
        "string-interning" => false,
        "unicode-normalization-checking" => true, #Nokogiri probably supports this, needs to be verified
        "use-attributes2" => false,
        "use-locator2" => false,
        "use-entity-resolver2" => false,
        "validation" => true, #Nokogiri is probably reporting erros
        "xmlns-uris" => true, #Nokogiri is probably treating xmlns declarations as part of xmlns namespace
        "xml-1.1" => false #Don't know
      }

      return features
    end
  end
end