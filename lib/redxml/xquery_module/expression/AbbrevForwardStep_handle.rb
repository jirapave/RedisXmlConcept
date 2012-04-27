require_relative "expression_module"
require_relative "expression_handle"

module XQuery
  module ExpressionModule 
    class AbbrevForwardStepHandle < ExpressionHandle #alias Element or Attribute handle
      
      attr_reader :value_type, :value_name
      
      
      #value types
      ELEMENT = :ELEMENT
      ATTRIBUTE = :ATTRIBUTE
      TEXT = :TEXT
      
      def initialize(node)
        super(node)
        
        #TODO delete
        # puts "   content: #{node.content}, node type: #{type}"
        #TODO delete
        
        #function test
        try_func = ExpressionModule::reduce(node)
        if(try_func.name == "TextTest")
          @value_type = TEXT
          @value_name = "text"
          return
        end
        
        @value_type = ELEMENT
        @value_name = node.children[0].content
        
        if(@value_name == "@")
          @value_type = ATTRIBUTE
          @value_name = node.children[1].content
        end
        
      end
      
      def type
        return AbbrevForwardStep
      end
      
    end
  end
end