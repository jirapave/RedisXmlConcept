require_relative "../xml/node"
require_relative "../xml/text_content"

module XQuery
  class NodeHelper
    
    def get_text(node)
      text = ""
      node.descendants.each { |n|
        if(n.kind_of?(XML::TextContent))
          text << n.text_content
        end
      }
      return text
    end
    
    
    
  end
end