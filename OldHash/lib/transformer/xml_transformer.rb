require_relative "../base_interface/db_interface"
require_relative "key"
require_relative "key_element_builder"
require_relative "../xml/node"
require_relative "../xml/document"
require_relative "../xml/text_content"
require_relative "../xml/element"

module Transformer
  #Prefixes of databases and collection didn't affect transformer, each Node know it's
  #key, e.g. collection and database
  class XMLTransformer
    attr_accessor :database, :collection, :mapping, :content_hash
    def initialize(database=-1, collection=-1)
      db = BaseInterface::DBInterface.instance
      @db_interface = db
      @builder = Transformer::KeyElementBuilder
      #Deprecated, we don't need them any more
      #TODO refactoring needed
      @database = database
      @collection = collection
      @mapping = {}
      @content_hash = ""
    end
    
    #Finds a node under the given key and build it's structure recursively.
    #Parameters:
    #key - Transformer::Key
    def find_node(key):Node
      
      if(key.instance_of? Transformer::Key)
        
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
        root_key_builder = Transformer::KeyElementBuilder.build_from_s(root_key)
        doc.root_element = find_node(root_key_builder)
        doc.root_element.name = get_elem_name(doc.root_element.name)
        return doc
        
      elsif(key.instance_of? Transformer::KeyElementBuilder)
        elem_name = get_elem_name(key.elem_name)
        ns_split = elem_name.split(':')
        namespace = false
        if(ns_split.length > 1)
          namespace = ns_split[0]
          elem_name = ns_split[1]
        end
        
        #create element (without parent so far)
        elem = XML::Element.new(elem_name, key.to_s, namespace, nil)
        
        #add attributes
        attrs = @db_interface.get_hash_value(@content_hash, key.attr)
        if attrs != nil
        attrs_hash = {}
        fields_only = []
        values_only = []
        attrs.split('|').each_with_index do |x, index|
          fields_only << x if index%2 == 0
          values_only << x if index%2 != 0
        end
        #Now we have fields and values apart
        fields_only.each_with_index do |field, index|
          attrs_hash[field] = values_only[index]
        end
        end
        
        elem.attributes = XML::Attributes.new(elem_name, attrs_hash)
        
        #add descendants
        desc_keys = @db_interface.get_hash_value(@content_hash, key.to_s)
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
              text_content = @db_interface.get_hash_value(@content_hash, key_str)
              elem.descendants << XML::TextContent.new(text_content, Transformer::KeyElementBuilder.text_order(key_str))
            else
              #Element
              child = find_node(Transformer::KeyElementBuilder.build_from_s(key_str))
              child.name = get_elem_name(child.name)
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
      main_hash = @content_hash
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
      attributes = ""
      iter = 0
      node.attributes.attrs.each do |key, value|
        attributes << key << "|" << value << "|"
        iter +=  1
      end
      @builder = Transformer::KeyElementBuilder.build_from_s(key)
      attr_key = @builder.attr
      @db_interface.add_to_hash(main_hash, [attr_key, attributes], true) if !attributes.empty?
    end
    
    def update_node(node)
      
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
    
  end
end