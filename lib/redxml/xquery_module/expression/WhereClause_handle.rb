require_relative "expression_module"
require_relative "expression_handle"
require_relative "ComparisonExpr_handle"

module XQuery
  module ExpressionModule
    class WhereClauseHandle < ExpressionHandle
      
      attr_reader :value
      
      def initialize(node)
        super(node)
        
        reduced = ExpressionModule::reduce(node.children[1])
        if(reduced.name == ComparisonExpr)
          @value = ComparisonExprHandle.new(reduced)
        else
          raise StandardError, "no other where clause implmenented: #{reduced.name}"
        end
        
      end
      
    end
  end
end