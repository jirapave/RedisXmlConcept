require_relative "expression_module"
require_relative "expression_handle"

module XQuery
  module ExpressionModule 
    class VarRefHandle < ExpressionHandle
      
      attr_reader :var_name
      
      def initialize(node)
        super(node)
        
        #TODO delete
        puts "initializing VarRef"
        #TODO delete
        
        @var_name = node.children[1].content
        
      end
      
    end
  end
end