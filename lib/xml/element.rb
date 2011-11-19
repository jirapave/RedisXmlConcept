require_relative "node"

module XML
  class Element < XML::Node
    def initialize(child_elements=false)
      child_elements ||= []
      @child_elements = child_elements
    end
  end
end