module Transformer
  #Prefixes of databases and collection didn't affect transformer, each Node know it's
  #key, e.g. collection and database
  class XMLTransformer
    def initialize(db_interface)
      @db_interface = db_interface
    end
    
    def find_node(key)
      
    end
    
    #There should be own error class if the key is not a node
    def remove_node(node)
      
    end
    
    def save_node(node)
      
    end
    
    def update_node(node)
      
    end
  end
end