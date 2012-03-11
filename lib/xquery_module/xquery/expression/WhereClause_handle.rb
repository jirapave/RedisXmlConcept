require_relative "expression_module"
require_relative "expression_handle"

module XQuery
  module ExpressionModule
    class WhereClauseHandle < ExpressionHandle
      
      attr_reader :value
      
      def initialize(node)
        super(node)
        
        #TODO delete
        puts "initializing WhereClause"
        #TODO delete
        
        reduced = ExpressionHandle::reduce(node.children[1])
        if(reduced.type == ComparisonExpr)
          @value = reduced
        else
          raise StandardError, "no other where clause implmenented: #{reduced.type}"
        end
        
      end
      
    end
  end
end