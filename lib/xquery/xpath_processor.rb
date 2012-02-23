module XQuery
  
  #interface for node and db xpath processor
  class XPathProcessor
    
    #should return all children (text and elements) - so array of nodes or ChildrenBean TODO do it better
    #so maybe array of nodes/keys - in both case Array object
    #maybe we dont need this public
    
    
    #return only element children (nodes or keys)
    def get_children_elements(value, match_elem_name="")
      raise NotImplementedError
    end
    
    def get_descendant_elements(value)
      raise NotImplementedError
    end
    
    def get_children_text(value)
      raise NotImplementedError
    end
    
    def get_attribute_hash(value)
      raise NotImplementedError
    end
    
    def get_text(value)
      raise NotImplementedError
    end
    
    def get_node(key)
      raise NotImplementedError
    end
    
    def get_node_content(key)#:String all descendants are turned into string
      raise NotImplementedError
    end
    
    def get_elem_index(elem_name)
      raise NotImplementedError
    end
    
  end
  
  class NotImplementedError < StandardError
  end
end