module XML
  class Node
    def initialize(name, key, namespace, parent)
      @attributes = []
      @database_key = key
      @descendants = []
      @name = name
      @namespace = namespace
      @parent = parent
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