require_relative "../base_interface/db_interface"

module Transformer
  #Prefixes of databases and collection didn't affect transformer, each Node know it's
  #key, e.g. collection and database
  class XMLTransformer
    attr_accessor :database, :collection
    def initialize(database=-1, collection=-1)
      db = BaseInterface::DBInterface.instance
      @db_interface = db
      @builder = Transformer::KeyBuilder
      #Added these because node will not know it's databse key, we will have to create it and for this
      #we have to know databse and collection, these should be set before saving
      @database = database
      @collection = collection
    end
    
    def find_node(key)
      
    end
    
    #There should be own error class if the key is not a node
    def remove_node(node)
      
    end
    
    def save_node(node)
      puts "Saving key of this element: #{node.database_key}"
      #puts "DESCENDANTS======"
      #node.descendants.each do |desc|
      #  if desc.instance_of? String
      #    puts "Descendant: #{desc}"
      #  else
      #    #Non-element
      #    puts "Descendant: #{desc.database_key}"
      #  end
      #end
      #puts "================"
      #puts "Attributes======"
      #Maybe we'll add each to Attributes class, so we don't have to use it like that
      #node.attributes.attributes.each do |key, value|
      #  puts "Attribure: #{key}=\"#{value}\""
      #end
      #puts "================"
      
      puts "======SAVING ELEMENT======="
      #So we have database key of a node, so let's save him to the database
      #First we have to save information about descendants
      key = node.database_key
      descendant_keys = []
      text_content = []
      node.descendants.each do |desc|
        if desc.instance_of? String
          descendant_keys << desc
        else
          #Non-element
          descendant_keys << desc.database_key
          if desc.text_node?
            text_content << desc.database_key 
            text_content << desc.text_content
          end
        end
      end
      puts "Saving information about descendants..."
      @db_interface.add_to_list(key, descendant_keys)
      
      #Than we will save information about text nodes
      @db_interface.save_string_entries(*text_content, true)
      
      #And lastly we have to save attributes and their order
      attributes = []
      #Ruby's hash order is ok since 1.9, but we don't know if Redis is ok too..so for now, order:
      attributes_order = []
      iter = 0
      node.attributes.attributes.each do |key, value|
        attributes << key << value
        attributes_order << key << iter
        iter +=  1
      end
      puts "savind information abour attributes..."
      attr_key = @builder.attributes_key(key)
      @db_interface.add_to_hash(attr_key, attributes, true) if !attributes.empty?
      
      attr_order_key = @builder.attributes_order_key(key)
      @db_interface.add_to_hash(attr_order_key, attributes_order, true) if !attributes.empty?
      puts "Saved node: #{node.database_key}"
      puts "======ELEMENT SAVED======="
    end
    
    def update_node(node)
      
    end
  end
end