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
        # temp = @db_interface.find_value(key.content_key)
        # puts "mapping====="
        # puts "#{mapping.inspect}"
        # puts "=================="
        # puts "#{temp.inspect}"
        # puts "=================="
        #return false
        
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
        elem_name = @elem_mapping[key.elem_name]
        ns_split = elem_name.split(':')
        namespace = false
        if(ns_split.length > 1)
          namespace = ns_split[0]
          elem_name = ns_split[1]
        end
        
        #create element (without parent so far)
        elem = XML::Element.new(elem_name, key.to_s, namespace, nil)
        
        #add attributes
        attrs_hash = get_attributes(key)
        elem.attributes = XML::Attributes.new(elem_name, attrs_hash)
        #add descendants
        desc_keys = @db_interface.get_hash_value(@key_builder.content_key, key.to_s)
        part_keys = []
        if desc_keys != nil
          desc_keys.split('|').each do |key|
            #Last one may be empty, we are adding those as << name << "|", so the last one is empty
            part_keys << key if key != ""
          end
        end
        
        if part_keys # if this element is not empty (like <element />)
          part_keys.each do |key_str|
            if(Transformer::KeyElementBuilder.text?(key_str))
              text_content = @db_interface.get_hash_value(@key_builder.content_key, key_str)
              elem.descendants << XML::TextContent.new(text_content, Transformer::KeyElementBuilder.text_order(key_str))
            else
              #Element
              child = find_node(Transformer::KeyElementBuilder.build_from_s(@key_builder, key_str))
              child.name = child.name
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
            text_content << desc.database_key 
            text_content << desc.text_content
          end
        end
      end
      @db_interface.add_to_hash(main_hash, [key, descendant_keys], false)
      
      
      #Than we will save information about text nodes
      if(!text_content.empty?)
        @db_interface.add_to_hash(main_hash, text_content, true)
      end
      
      #And at last we have to save attributes and their order
      save_attributes(node)
    end
    
    def update_node(node)
      
    end
    
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
    
    def get_attributes(key_elem_builder)
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
            attr_name = @attr_mapping[field]
            attrs_hash[attr_name] = values_only[index]
          end
        end
        return attrs_hash
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