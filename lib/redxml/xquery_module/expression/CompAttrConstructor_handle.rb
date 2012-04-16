require_relative "expression_module"
require_relative "expression_handle"

module XQuery
  module ExpressionModule
    class CompAttrConstructorHandle < ExpressionHandle
      
      attr_reader :attr_name, :attr_value
      
      def initialize(node)
        super(node)
        
        #TODO delete
        puts "initializing CompAttrConstructor"
        #TODO delete
        
        @attr_name = node.children[1].content
        @attr_value = ExpressionModule::reduce(node.children[3])
        if(@attr_value.name == StringLiteral)
          @attr_value = @attr_value.content[1..-2]
        else
          @attr_value = @attr_value.content
        end
        puts @attr_value
        
      end
      
    end
  end
end