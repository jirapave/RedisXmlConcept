module XQuery
  
  #interface for node and db xpath processor
  class XPathProcessor
    
    #should return all children (text and elements) - so array of nodes or ChildrenBean TODO do it better
    #so maybe array of nodes/keys - in both case Array object
    #maybe we dont need this public
    
    
    #stripped: true/false
    def get_text(elem, stripped)
      raise NotImplementedError
    end
    
    def get_node_content(elem)
      raise NotImplementedError
    end
    
    def get_children_elements(elem, match_elem_name="*")
      raise NotImplementedError
    end
    
    def get_descendant_elements(elem)
      raise NotImplementedError
    end
    
    def get_node(elem)
      raise NotImplementedError
    end
    
    def get_attribute(elem, attr_name)
      raise NotImplementedError
    end
    
  end
  
  class NotImplementedError < StandardError
  end
end