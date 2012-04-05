require_relative "path_processor"
require "rubygems"
require "nokogiri"

module XQuery
  class NodePathProcessor < PathProcessor
    
    #DEPRICATED - currently not needed
    
    def valid_elem?(incomming) #return true/false
      return incomming.kind_of?(Nokogiri::XML::Node) 
    end
    
    def get_text(node)
      return node.xpath("./text()")
    end
    
    def get_descendant_texts(node)
      return node.xpath(".//text()")
    end
    
    def get_node_content(node)
      return node.content
    end
    
    def get_children_elements(node, match_elem_name="*")
      return node.xpath("./#{match_elem_name}")
    end
    
    def get_descendant_elements(node, match_elem_name="*")
      return node.xpath(".//#{match_elem_name}")
    end
    
    def get_node(node)
      return node
    end
    
    def get_attribute(node, attr_name)
      return node.xpath("./@#{attr_name}")
    end
    
  end
end