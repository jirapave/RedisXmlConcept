require_relative "xpath_processor"

module XQuery
  class NodeXPathProcessor < XPathProcessor
    
    
    #TODO TODO TODO - untested so far!!
    
    #stripped: true/false
    def get_text(node, stripped)
      text = ""
      node.descendants.each { |descendant|
        if(descendant.kind_of?(XML::TextContent))
          t = descendant.text_content
          t = t.strip if(stripped)
          text << t
        end
      }
      return text
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
    
    def get_descendant_elements(node)
      start_node_array = []
      start_node_array.concat(get_children_elements(node))
      
      all_round_nodes = []
      all_round_nodes.concat(start_node_array)
      start_node_array.each { |start_node|
        all_round_nodes.concat(get_descendant_elements(start_node))
      }
      
      return all_round_keys
    end
    
    def get_attribute(node, attr_name)
      attr_hash = node.attributes.attrs
      return attr_hash[attr_name]
    end
    
  end
end