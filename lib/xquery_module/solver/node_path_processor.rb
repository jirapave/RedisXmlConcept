require_relative "path_processor"

module XQuery
  class NodePathProcessor < PathProcessor
    
    
    def valid_elem?(incomming) #return true/false
      return incomming.kind_of?(XML::Node) 
    end
    
    #stripped: true/false
    def get_text(node, stripped)
      return get_texts(node, stripped).join
    end
    
    def get_descendant_texts(node, stripped)
      results = [ get_text(node, stripped) ]
      descendants = get_desc_elements(node)
      descendants.each { |desc|
        results << get_text(desc, stripped)
      }
      return results
    end
    
    def get_texts(node, stripped)
      texts = []
      node.descendants.each { |descendant|
        if(descendant.kind_of?(XML::TextContent))
          t = descendant.text_content
          t = t.strip if(stripped)
          text << t
        end
      }
      return texts
    end
    
    def get_node_content(node)
      content = ""
      node.descendants.each { |descendant|
        content << descendant.to_stripped_s
      }
      return content
    end
    
    def get_children_elements(node, match_elem_name="*")
      node_array = []
      node.descendants.each { |descendant|
        if(descendant.kind_of?(XML::Element) && (match_elem_name == "*" || descendant.name == match_elem_name))
          node_array << descendant
        end
      }
      return node_array
    end
    
    def get_descendant_elements(node, match_elem_name="*")
      node_array = []
      all_nodes = get_desc_elements(node)
      all_nodes.each { |n|
        if(n.kind_of?(XML::Element) && (match_elem_name == "*" || n.name == match_elem_name))
          node_array << n
        end
      }
      
      return node_array
    end
    
    def get_attribute(node, attr_name)
      attr_hash = node.attributes.attrs
      return attr_hash[attr_name]
    end
    
  private
    def get_desc_elements(node)
      start_node_array = []
      start_node_array.concat(get_children_elements(node))
      
      all_round_nodes = []
      all_round_nodes.concat(start_node_array)
      start_node_array.each { |start_node|
        all_round_nodes.concat(get_descendant_elements(start_node))
      }
      
      return all_round_keys
    end
    
  end
end