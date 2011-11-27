require_relative "node"

module XML
  class Element < XML::Node
    attr_reader :child_elements, :text_nodes_count
    def initialize(name, key, namespace, parent, child_elements=false)
      super(name, key, namespace, parent)
      child_elements ||= []
      @child_elements = child_elements
      #order of this element in it's parent descendants with the same name, example:
      #<aaa><bbb id="1"/><ccc/><bbb id="2"/></aaa>, first bb has order = 0, second has order 1
      @text_nodes_count = 0
    end
    
    def add_child(child)
      @child_elements << child
      @descendants << child
    end
    
    def add_text(text_node)
      @descendants << text_node
      @text_nodes_count += 1
    end
  end
end