require_relative "attributes"

module XML
  # Basic class to represent common properties of document and elements as in DOM
  class Node
    
    TAB_LENGTH = 4
    
    attr_accessor :attributes, :descendants, :name, :namespace, :parent, :order, :database_key
    def initialize(name, key, namespace, parent)
      @attributes = XML::Attributes.new(name, {})
      @descendants = []
      @name = name
      @namespace = namespace
      @parent = parent
      @order = 0
      @database_key = key
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
    
    def to_s()
      Node.get_node_s(self)
    end
    
    def to_stripped_s()
      Node.get_node_strip(self)
    end
    
    # recursively called get_node_s to retrieve proper node string
    def self.get_node_s(node, tabcount=0, last_text_content=false)#:String
      str = ""
      if(node.instance_of? Document)
        str += "#{node.metadata}\n"
        str += Node.get_node_s(node.root_element)
      elsif(node.instance_of? Element)
        str += "#{Node.get_tab_s(tabcount)}<#{node.name}#{get_attrs(node)}>\n"
        node.descendants.each { |descendant|
          str += Node.get_node_s(descendant, tabcount+1)
        }
        str += "#{Node.get_tab_s(tabcount)}</#{node.name}>\n"
      elsif(node.instance_of? TextContent)
        case node.type
          when XML::TextContent::PLAIN
            str += "#{Node.get_tab_s(tabcount)}#{node.text_content}\n"
          when XML::TextContent::COMMENT
            str += "#{Node.get_tab_s(tabcount)}<!-- #{node.text_content} -->\n"
          when XML::TextContent::CDATA
            str += "#{Node.get_tab_s(tabcount)}<![CDATA[#{node.text_content}]]>\n"
        end
      end
      return str
    end
    
    def self.get_node_strip(node, last_text_content=false)#:String
      str = ""
      if(node.instance_of? Document)
        str += "#{node.metadata}"
        str += Node.get_node_strip(node.root_element)
      elsif(node.instance_of? Element)
        str += "<#{node.name}#{get_attrs(node)}>"
        node.descendants.each { |descendant|
          str += Node.get_node_strip(descendant)
        }
        str += "</#{node.name}>"
      elsif(node.instance_of? TextContent)
        case node.type
          when XML::TextContent::PLAIN
            str += "#{node.text_content}"
          when XML::TextContent::COMMENT
            str += "<!-- #{node.text_content} -->"
          when XML::TextContent::CDATA
            str += "<![CDATA[#{node.text_content}]]>"
        end
      end
      return str
    end
    
  private
    def self.get_tab_s(tabcount):String
      s = ""
      (tabcount*TAB_LENGTH).times { s += " " }
      return s
    end
    
    def self.get_attrs(node):String
      s = ""
      node.attributes.attrs.each do |key, value|
        s += " #{key}=\"#{value}\""
      end
      return s
    end
  end
end