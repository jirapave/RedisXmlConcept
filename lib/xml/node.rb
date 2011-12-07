module XML
  class Node
    
    TAB_LENGTH = 4
    
    attr_accessor :attributes, :nesting, :descendants, :name, :namespace, :parent, :order, :database_key
    def initialize(name, nesting, namespace, parent)
      #TODO Attributes are not array, they have their own class
      @attributes = XML::Attributes.new(name, {})
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
    
    def to_s():String
      Node.get_node_s(self)
    end
    
    
    # recursively called get_node_s to retrieve proper node string
    def self.get_node_s(node, tabcount=0, last_text_content=false):String
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
        str += "#{Node.get_tab_s(tabcount)}#{node.text_content}\n"
      end
      return str
    end
    
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