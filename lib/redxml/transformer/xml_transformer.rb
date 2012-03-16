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
    ATTR_SEPARATOR = "|"
    
    # Creates new instance of XmlTransformer to work with document.
    # ==== Parameters
    # * +key_builder+ - KeyBuilder which is used to determine the document with which we are working
    def initialize(key_builder)
      @db_interface = BaseInterface::DBInterface.instance
      @key_builder = key_builder
      @elem_mapping = {}
      @attr_mapping = {}
      @doc = nil
    end
    
    # Currently not implemented
    def remove_node(node)
      
    end
    
    # Saves a given node in a database, node knows it's database key under which it should be saved. Node
    # is saved recursively, so if we pass root element, whole document will be saved.
    # ==== Parameters
    # * +node+ - XML::Node
    def save_node(node)
      main_hash = @key_builder.content_key
      key = node.database_key
      descendant_keys = ""
      child_keys = ""
      text_content = []
      node.descendants.each do |desc|
        if desc.instance_of? String
          descendant_keys << desc << "|"
          child_keys << desc << "|"
        else
          #Non-element
            descendant_keys << desc.database_key << "|"
          if desc.text_node?
            #text_node is plain text, commnt and cdata, sax_parser is creating keys for them, we don't bother here
            text_content << desc.database_key 
            text_content << desc.text_content
          end
        end
      end
      @db_interface.add_to_hash(main_hash, [key, descendant_keys], true)
      
      
      #Than we will save information about text nodes
      if(!text_content.empty?)
        @db_interface.add_to_hash(main_hash, text_content, true)
      end
      
      #And at last we have to save attributes and their order
      save_attributes(node)
    end
    
    # Currently not implemented
    def update_node(node)
      
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
            attr_name = @mapping_service.unmap_attr_name field
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
        
      builder = Nokogiri::XML::Builder.with(doc) do |xml|
        root_key = info_hash["root"]
        root_key_builder = Transformer::KeyElementBuilder.build_from_s(key_builder, root_key)
        build_node(root_key_builder, xml)
      end
      return builder.doc
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
        xml["#{namespace}"] if namespace
        
        #Creating element with a given name and attributes, xmlns attributes are automaticaly parsed
        #as namesace declarations
        xml.send("#{elem_name}", attrs_hash) do |elem_xml|
        
        #add descendants
          desc_keys = @db_interface.get_hash_value(@key_builder.content_key, key.to_s)
          part_keys = []
          if desc_keys != nil
            desc_keys.split('|').each do |key|
             #Last one may be empty, we are adding those as << name << "|", so the last one is empty
             part_keys << key if key != ""
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
    
    # Retrieves specified element.
    # ==== Parameters
    # * +key_elem_builder+ - KeyElementBuilder instance to specify a node to be retrieved
    # ==== Return value
    # Nokogiri::XML::Node instance 
    def get_node(key_elem_builder)
      @mapping_service = Transformer::MappingService.new(key_elem_builder.key_builder)
      builder = Nokogiri::XML::Builder.new do |xml|
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
    
  end
end