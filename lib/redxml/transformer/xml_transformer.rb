require_relative "../base_interface/db_interface"
require_relative "key_element_builder"
require_relative "../xml/node"
require_relative "../xml/document"
require_relative "../xml/text_content"
require_relative "../xml/element"
require "nokogiri"

module Transformer
  # This class is used as a simple abstract layer to work with documents (document is based on KeyBuilder given
  # as an init parameter). It supports saving and retrieving nodes recursively.
  class XMLTransformer
    
    # Separator of attributes, those are saved in one string with separator as delimiter
    ATTR_SEPARATOR = "\""
    # Separator of direct descendants of the certain element, used as delimiter
    DESC_SEPARATOR = "|"
    
    attr_reader :mapping_service
    
    # Creates new instance of XmlTransformer to work with document.
    # ==== Parameters
    # * +key_builder+ - KeyBuilder which is used to determine the document with which we are working
    def initialize(key_builder)
      @db_interface = BaseInterface::DBInterface.instance
      @mapping_service = Transformer::MappingService.new(key_builder)
      @key_builder = key_builder
      @elem_mapping = {}
      @attr_mapping = {}
      @doc = nil
    end
    
    # Generates SAX events fo the specified node
    # ==== Parameters
    # * +key_elem_builder+ - KeyElementBuilder which is used to determine the node for which the
    #                        SAX events should generated
    def generate_node_sax_events(key_elem_builder)
      # Element preparation
      elem_name = @mapping_service.unmap_elem_name key_elem_builder.elem_id
      ns_split = elem_name.split(':')
      namespace = nil
      if(ns_split.length > 1)
        namespace = ns_split[0]
        elem_name = ns_split[1]
      end
        
      # Attributes preparation
      attrs = @db_interface.get_hash_value(@key_builder.content_key, key_elem_builder.attr)
      fields_only = []
      values_only = []
      if attrs != nil
        attrs.split(ATTR_SEPARATOR).each_with_index do |x, index|
          fields_only << @mapping_service.unmap_attr_name(x) if index%2 == 0
          values_only << x if index%2 != 0
        end
      end
        
      # Handle element namespace, we have to find it's URI
      attrs = []
      prefix = namespace # Element prefix
      uri = nil
      ns = []
      
      # Handle attributes and their namespaces
      fields_only.each_with_index do |field, index|
        parts = field.split(":")
        if parts[0] == "xmlns" #Namespace declaration
          result = [parts[1..-1].join(":"), values_only[index]]
          ns << result
          @ns << result
        elsif parts.length > 1 #Attribute with namespace
          pref = parts[0] # Attribute prefix
          name = parts[1..-1].join(":") # Recover attribute name
          # Now we have to get uri, uris are saved under @ns variable
          attr_uri = nil
          @ns.each do |decl|
            if decl[0] == pref
              attr_uri = decl[1]
            end
          end
          raise StandardError, "XML is not a valid document, attribute used undeclared namespace" unless attr_uri
          #Now we have all the information needed
          info = Nokogiri::XML::SAX::Parser::Attribute.new
          info.localname = name
          info.prefix = pref
          info.uri = attr_uri
          info.value = values_only[index]
          attrs << info
        else # Basic attriute with name and value
          info = Nokogiri::XML::SAX::Parser::Attribute.new
          info.localname = parts[0]
          info.value = values_only[index]
          attrs << info 
        end
      end
      
      # Now we have parsed all possible attributes and xmlns declarations, so we have to verify URI
      if prefix
        @ns.each do |decl|
          if decl[0] == prefix
            uri = decl[1]
          end
        end
        raise StandardError, "XML is not a valid document, element used undeclared namespace" unless uri
      end
      
      # Element completely read, event start_element can now be launched
      @handler.start_element_namespace(elem_name, attrs, prefix, uri, ns)
      
      # Format of attribs
      # [ ["xmlns:foo", "http://sample.net"], ["size", "large"] ]
      name = [prefix, elem_name].compact.join(':')
      attribs = ns.map { |ns_prefix,ns_uri|
        [['xmlns', ns_prefix].compact.join(':'), ns_uri]
      } + attrs.map { |attr|
        [[attr.prefix, attr.localname].compact.join(':'), attr.value]
      }
      @handler.start_element(name, attribs)
      
        
        #<root xmlns:a=\"http://www.neco.com/a\"><a:book a:info=\"aaaa\" 
        #xmlns:b=\"http://www.blbla.com/u\">Pad Hyperionu</book></root>"
        #Produces 
        #attrs: [#<struct Nokogiri::XML::SAX::Parser::Attribute localname="info", prefix="a", uri="http://www.neco.com/a", value="aaaa">]
        #prefix: a
        #uri: http://www.neco.com/a
        #ns: [["b", "http://www.blbla.com/u"]] 
        
      desc_keys = @db_interface.get_hash_value(@key_builder.content_key, key_elem_builder.to_s)
      part_keys = []
      if desc_keys != nil
        desc_keys.split(DESC_SEPARATOR).each do |key|
          part_keys << key
        end
      end
        
      if part_keys # if this element is not empty (like <element />
        part_keys.each do |key_str|
          type = Transformer::KeyElementBuilder.text_type(key_str)
          if type
            text_content = @db_interface.get_hash_value(@key_builder.content_key, key_str)
            case type
              when XML::TextContent::PLAIN
                @handler.characters(text_content)
              when XML::TextContent::COMMENT
                @handler.comment(text_content)
              when XML::TextContent::CDATA
                @handler.cdata_block(text_content)
            end
          else
            #Child element
            generate_node_sax_events(Transformer::KeyElementBuilder.build_from_s(@key_builder, key_str))
          end
        end
      end
      
      #Now end_elemeny events
      @handler.end_element_namespace(elem_name, prefix, uri)
      @handler.end_element(name)
    end
    
    # Load document from the database in the form of SAX events which are sent into given
    # handler
    # ==== Parameters
    # * +key_builder+ - KeyBuilder which determines document to be retrieved
    # * +handler+ - implementation of Nokogiri::XML::SAX::Document
    def get_document_as_sax(key_builder, handler)
      @handler = handler
      
      @mapping_service = Transformer::MappingService.new(key_builder)
      info_hash = @db_interface.find_value(key_builder.info)
      @handler.xmldecl(info_hash["version"], info_hash["encoding"], info_hash["standalone"])
        
      root_key = info_hash["root"]
      #TODO generate start document and decaration
      root_key_builder = Transformer::KeyElementBuilder.build_from_s(key_builder, root_key)
      @ns = [] #Contains declared namespaces
      @handler.start_document
      generate_node_sax_events(root_key_builder)
      @handler.end_document
    end
    
    # Saves a given node in a database, node knows it's database key under which it should be saved. Node
    # is saved recursively, so if we pass root element, whole document will be saved.
    # ==== Parameters
    # * +node+ - XML::Node
    def save_node(node)
      main_hash = @key_builder.content_key
      key = node.database_key
      descendant_keys = ""
      text_content = []
      node.descendants.each do |desc|
        if desc.instance_of? String
          descendant_keys << desc << DESC_SEPARATOR
        else
          descendant_keys << desc.database_key << DESC_SEPARATOR
          if desc.text_node?
            #text_node is plain text, commnt and cdata, sax_parser is creating keys for them, we don't bother here
            text_content << desc.database_key 
            text_content << desc.text_content
          end
        end
      end
      if descendant_keys != ""
        descendant_keys = descendant_keys[0..-2] # Delete useless delimiter at the end
        @db_interface.add_to_hash(main_hash, [key, descendant_keys], true)
      end
      
      
      #Than we will save information about text nodes
      if(!text_content.empty?)
        @db_interface.add_to_hash(main_hash, text_content, true)
      end
      
      #And at last we have to save attributes and their order
      save_attributes(node)
    end
    
    # Saves attributes of a given node in a database, remember that node itself know database key
    # under which it should be saved.
    # ==== Parameters
    # * +node+ - XML::Node
    # ==== Return value
    # True if attributes were saved, False if there wasn't any attributes to save
    def save_attributes(node)
      attr_arr = []
      iter = 0
      node.attributes.attrs.each do |key, value|
        attr_arr << key << value
        iter +=  1
      end
      attributes = attr_arr.join("#{ATTR_SEPARATOR}" )
      attr_key = Transformer::KeyElementBuilder.build_from_s(@key_builder, node.database_key).attr
      if !attributes.empty?
        @db_interface.add_to_hash(@key_builder.content_key, [attr_key, attributes], true) 
        return true
      end
      return false
    end
    
    # Get all attributes of the element specified by KeyElementBuilder.
    # ==== Parameters
    # * +key_elem_builder+ - KeyElementBuilder
    # * +mapped+ - Determines if the returned attributes contains real names or IDs
    # ==== Return value
    # Hash where field is name of the attribute and value is obviously value.
    def get_attributes(key_elem_builder, mapped=true)
      attrs = @db_interface.get_hash_value(@key_builder.content_key, key_elem_builder.attr)
        if attrs != nil
          attrs_hash = {}
          fields_only = []
          values_only = []
          attrs.split(ATTR_SEPARATOR).each_with_index do |x, index|
            fields_only << x if index%2 == 0
            values_only << x if index%2 != 0
          end
          #Now we have fields and values apart
          fields_only.each_with_index do |field, index|
            attr_name = field
            #attr_name = @attr_mapping[field] if mapped
            attr_name = @mapping_service.unmap_attr_name field if mapped
            attrs_hash[attr_name] = values_only[index]
          end
        end
        return attrs_hash
    end
    
    # Retrieves a document under certain key represented as a key parameter.
    # ==== Parameters
    # * +key+ - KeyBuilder instane to specify a document to be retrieved
    # ==== Return value
    # Nokogiri::XML::Document instance 
    def get_document(key_builder)
      @mapping_service = Transformer::MappingService.new(key_builder)
      info_hash = @db_interface.find_value(key_builder.info)
      if info_hash["root"] == nil #document is empty
        builder = Nokogiri::XML::Builder.new
        return builder.doc
      end
      #Probably the only way how to set standalone, Nokogiri::XML::Document doesn't allow to set standalone
      #otherwise, only encoding and version
      doc = "<?xml version=\"#{info_hash["version"]}\" encoding=\"#{info_hash["encoding"]}\" standalone=\"#{info_hash["standalone"]}\" ?>"
      doc = Nokogiri::XML(doc)
      
      @ns = @db_interface.find_value(key_builder.namespace_key)
      
      builder = Nokogiri::XML::Builder.with(doc) do |xml|
        root_key = info_hash["root"]
        root_key_builder = Transformer::KeyElementBuilder.build_from_s(key_builder, root_key)
        build_node(root_key_builder, xml)
      end
      return builder.doc
    end
    
    # Retrieves specified element.
    # ==== Parameters
    # * +key_elem_builder+ - KeyElementBuilder instance to specify a node to be retrieved
    # ==== Return value
    # Nokogiri::XML::Node instance 
    def get_node(key_elem_builder)
      @ns = @db_interface.find_value(key_elem_builder.key_builder.namespace_key)
      builder = Nokogiri::XML::Builder.new do |xml|
        if @ns 
          @ns.each do |field, value| 
            xml.parent.add_namespace_definition(field, value)
          end
        end
        build_node(key_elem_builder, xml)
      end
      return builder.doc.root
    end
    
    private 
    def get_elem_name(id)# :nodoc:
      mapping.each do |key, value|
        if (id == value)
          return key
        end
      end
      return id
    end
    
    # Finds a node under the given key and build it's structure recursively. When called on root, whole
    # document is retrieved. Result is added under the content specified by xml parameter. This parameter
    # represents block parameter Nokogiri::XML::Builder.new { |xml| }
    # ==== Parameters
    # * +key+ - KeyElementBuilder to specify a node
    # * +xml+ - Context under which should the element be retrieved. This context can be created by using
    #           Nokogiri::XML::Builder.new { |xml|} or Nokogiri::XML::Builder.with(doc_or_elem) { |xml|}
    def build_node(key, xml)
        elem_name = @mapping_service.unmap_elem_name key.elem_id
        ns_split = elem_name.split(':')
        namespace = nil
        if(ns_split.length > 1)
          namespace = ns_split[0]
          elem_name = ns_split[1]
        end
        
        attrs_hash = get_attributes(key)
        
        #This will ad namespace to the current element in xml, raise ArgumentError if given namespace
        #dos not exist = hasn't been defined in xmlns attribute   
        xml[namespace] if namespace
        #Creating element with a given name and attributes, xmlns attributes are automaticaly parsed
        #as namesace declarations
        # Note: Underscore is crucial here, it is used to disambiguate ruby internal calls
        # for detailed information see: http://nokogiri.org/Nokogiri/XML/Builder.html
        # section special tags
        xml.send("#{elem_name}_", attrs_hash) do |elem_xml|
          # This is crucial, Nokogiri uilder automatically adds namespaces into children
          # if we don't explicily delete them
          elem_xml.parent.namespace = nil unless namespace
          #add descendants
          desc_keys = @db_interface.get_hash_value(@key_builder.content_key, key.to_s)
          part_keys = []
          if desc_keys != nil
            desc_keys.split(DESC_SEPARATOR).each do |key|
             part_keys << key
            end
          end
        
           if part_keys # if this element is not empty (like <element />
             part_keys.each do |key_str|
               type = Transformer::KeyElementBuilder.text_type(key_str)
               if type
                 text_content = @db_interface.get_hash_value(@key_builder.content_key, key_str)
                 case type
                   when XML::TextContent::PLAIN
                     elem_xml.text text_content
                   when XML::TextContent::COMMENT
                     elem_xml.comment text_content
                   when XML::TextContent::CDATA
                     elem_xml.cdata text_content
                 end
               else
                 #Child element
                 build_node(Transformer::KeyElementBuilder.build_from_s(@key_builder, key_str), elem_xml)
               end
             end
           end
         end
    end
  end
end