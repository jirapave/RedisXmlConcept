require_relative "../base_interface/db_interface"
require_relative "key_element_builder"
require_relative "../xml/node"
require_relative "../xml/document"
require_relative "../xml/text_content"
require_relative "../xml/element"

module Transformer
  #Prefixes of databases and collection didn't affect transformer, each Node know it's
  #key, e.g. collection and database
  class XMLTransformer
    ATTR_SEPARATOR = "\""
    
    def initialize(key_builder)
      @db_interface = BaseInterface::DBInterface.instance
      @key_builder = key_builder
      @elem_mapping = {}
      @attr_mapping = {}
    end
    
    #Finds a node under the given key and build it's structure recursively.
    #Parameters:
    #key - Transformer::Key
    def find_node(key):Node
      load_mappings() if @elem_mapping.empty?
      if(key.instance_of? Transformer::KeyBuilder)
        
        info_hash = @db_interface.find_value(key.info)
        
        doc = XML::Document.new()
        doc.file_name = info_hash["name"]
        doc.version = info_hash["version"]
        doc.encoding = info_hash["encoding"]
        doc.standalone = info_hash["standalone"]
        
        root_key = info_hash["root"]
        root_key_builder = Transformer::KeyElementBuilder.build_from_s(@key_builder, root_key)
        doc.root_element = find_node(root_key_builder)
        doc.root_element.name = doc.root_element.name
        return doc
        
      elsif(key.instance_of? Transformer::KeyElementBuilder)
        elem_name = @elem_mapping[key.elem_id]
        ns_split = elem_name.split(':')
        namespace = false
        if(ns_split.length > 1)
          namespace = ns_split[0]
          elem_name = ns_split[1]
        end
        
        #create element (without parent so far)
        elem = XML::Element.new(elem_name, key.to_s, namespace, nil)
        
        #add attributes
        attrs_hash = get_attributes(key, elem_name)
        
        elem.attributes = XML::Attributes.new(elem_name, attrs_hash) if attrs_hash
        #add descendants
        #add descendants
        part_keys = @db_interface.find_value(key.to_s)
        
        if part_keys # if this element is not empty (like <element />)
          part_keys.each do |key_str|
            if(Transformer::KeyElementBuilder.text?(key_str))
              text_content = @db_interface.find_value(key_str)
              elem.descendants << XML::TextContent.new(text_content, Transformer::KeyElementBuilder.text_order(key_str))
            else
              #Element
              key_str = key_str.split(":")[3..-1].join(":")
              child = find_node(Transformer::KeyElementBuilder.build_from_s(@key_builder, key_str))
              child.parent = elem
              elem.descendants << child
            end
          end
        end
        return elem
      end
    end
    
    #There should be own error class if the key is not a node
    def remove_node(node)
      
    end
    
    #Saves a given node in a database, node knows it's database key under which it should be saved.
    #Node contains only databse key of it's child elements so we can avoid memory requirements when
    #parsing document.
    #Parameters:
    #node - XML::Node
    #main_hash - key to hash table, where all information about node will be saved
    def save_node(node)
      key = node.database_key
      descendant_keys = []
      child_keys = []
      text_content = []
      node.descendants.each do |desc|
        if desc.instance_of? String
          descendant_keys << desc
          child_keys << desc
        else
          #Non-element
          descendant_keys << desc.database_key
          if desc.text_node?
            text_content << desc.database_key 
            text_content << desc.text_content
          end
        end
      end
      @db_interface.add_to_list(key, descendant_keys)
      
      #Than we will save information about text nodes
      if(!text_content.empty?)
        @db_interface.save_string_entries(*text_content, true)
      end
      
      #And at last we have to save attributes and their order
      save_attributes(node)
    end
    
    def update_node(node)
      
    end
    
    def save_attributes(node)
      #And at last we have to save attributes and their order
      attributes = []
      iter = 0
      node.attributes.attrs.each do |key, value|
        attributes << key << value
        iter +=  1
      end
      attr_key = Transformer::KeyElementBuilder.attr(node.database_key)
      @db_interface.add_to_hash(attr_key, attributes, true) if !attributes.empty?
    end
    
    def get_attributes(key_elem_builder, elem_name)
      #add attributes in the right order
        attrs_hash = @db_interface.find_value(Transformer::KeyElementBuilder.attr("#{key_elem_builder}"))
        return {} unless attrs_hash
        attributes = {}
        attrs_hash.each do |field, value|
          attributes[@attr_mapping[field]] = value
        end
        return attributes
    end
    
    private 
    def get_elem_name(id)
      mapping.each do |key, value|
        if (id == value)
          return key
        end
      end
      return id
    end
    
    def load_mappings
      @elem_mapping = @db_interface.find_value(@key_builder.elem_mapping_key)
      @attr_mapping = @db_interface.find_value(@key_builder.attr_mapping_key)

      #Now we will reverse them so we can get O(1) complexity of finding name
      temp = {}
      @elem_mapping.each do |key, value|
        temp["#{value}"] = key
      end
      @elem_mapping = temp
      temp = {}
      @attr_mapping.each do |key, value|
        temp["#{value}"] = key
      end
      @attr_mapping = temp
    end
    
  end
end