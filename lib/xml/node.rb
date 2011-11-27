module XML
  class Node
    attr_accessor :attributes, :nesting, :descendants, :name, :namespace, :parent, :order, :database_key
    def initialize(name, nesting, namespace, parent)
      #TODO Attributes are not array, they have their own class
      @attributes = []
      #Changed for now, node will not know about it's database key, it will know however it's nesting
      #so we can create database_key from it after
      @nesting = nesting
      @descendants = []
      @name = name
      @namespace = namespace
      @parent = parent
      @order = 0
      @database_key = ""
    end
    
    def element_node?()
      return true if self.instance_of? Node
      false
    end
    
    def text_node?()
      #Does this work without require?
      return true if self.instance_of? TextContent
      false
    end
    
    def get_next_sibling()
      
    end
    
    def get_previous_sibling()
      
    end
  end
end