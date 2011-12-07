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
    attr_accessor :database, :collection
    def initialize(database=-1, collection=-1)
      db = BaseInterface::DBInterface.instance
      @db_interface = db
      @builder = Transformer::KeyBuilder
      #Deprecated, we don't need them any more
      #TODO refactoring needed
      @database = database
      @collection = collection
    end
    
    #Finds a node under the given key and build it's structure recursively.
    #Parameters:
    #key - Transformer::Key
    def find_node(key):Node
      
      if(key.instance_of? Transformer::Key)
        
        info_hash = @db_interface.find_value(key.info)
        
        doc = XML::Document.new()
        doc.file_name = info_hash["name"]
        doc.version = info_hash["version"]
        doc.encoding = info_hash["encoding"]
        doc.standalone = info_hash["standalone"]
        
        root_key = info_hash["root"]
        root_key_builder = Transformer::KeyElementBuilder.build_from_s(root_key)
        doc.root_element = find_node(root_key_builder)
        
        return doc
        
      elsif(key.instance_of? Transformer::KeyElementBuilder)

        elem_name = key.elem_name
        ns_split = elem_name.split(':')
        namespace = false
        if(ns_split.length > 1)
          namespace = ns_split[0]
          elem_name = ns_split[1]
        end
        
        #create element (without parent so far)
        elem = XML::Element.new(elem_name, key.to_s, namespace, nil)
        
        #add attributes in the right order
        attrs_hash = @db_interface.find_value(key.attr)
        if(attrs_hash)
          # attr_order = @db_interface.find_value(key.attr_order)
#           
          # #array with sorted attributes
          # attr_order_a = []
#           
          # #sort them into the array
          # attr_order.each { |key, value|
            # attr_order_a[value.to_i] = key
          # }
#           
          # #add sorted attributes to Node.attributes
          # attr_order_a.each { |hash_key|
            # elem.attributes << XML::Attr.new(hash_key, elem, attrs_hash[hash_key]) 
          # }
          elem.attributes = XML::Attributes.new(elem_name, attrs_hash)
        end
        
        #add descendants
        part_keys = @db_interface.find_value(key.to_s)
        
        if part_keys # if this element is not empty (like <element />)
          part_keys.each do |key_str|
            if(Transformer::KeyElementBuilder.text?(key_str))
              text_content = @db_interface.find_value(key_str)
              elem.descendants << XML::TextContent.new(false, text_content, Transformer::KeyElementBuilder.text_order(key_str))
            else
              #Element
              child = find_node(Transformer::KeyElementBuilder.build_from_s(key_str))
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
      
      #saving descendant counts
      child_hash = Hash.new
      child_keys.each do |child|
        child_count_key = Transformer::KeyElementBuilder.build_from_s(child).count
        child_count = child_hash[child_count_key]
        if(child_count)
          child_count = child_count.to_i + 1
          child_hash[child_count_key] = child_count
        else
          child_hash[child_count_key] = 1
        end
      end
      #DEBUG
      if(!child_hash.empty?)
        @db_interface.save_entries(child_hash, true)
      end
      
      
      #Than we will save information about text nodes
      if(!text_content.empty?)
        @db_interface.save_string_entries(*text_content, true)
      end
      
      #save text count
      if(!text_content.empty?)
        text_count_key = Transformer::KeyElementBuilder.build_from_s(text_content[0]).text_count
        text_count_value = (text_content.length/2).to_s
        @db_interface.save_string_entries(text_count_key, text_count_value, true)
      end
      
      #And at last we have to save attributes and their order
      attributes = []
      #Ruby's hash order is ok since 1.9, but we don't know if Redis is ok too..so for now, order:
      attributes_order = []
      iter = 0
      node.attributes.attrs.each do |key, value|
        attributes << key << value
        attributes_order << key << iter
        iter +=  1
      end
      attr_key = @builder.attributes_key(key)
      @db_interface.add_to_hash(attr_key, attributes, true) if !attributes.empty?
      
      attr_order_key = @builder.attributes_order_key(key)
      @db_interface.add_to_hash(attr_order_key, attributes_order, true) if !attributes.empty?
    end
    
    def update_node(node)
      
    end
  end
end