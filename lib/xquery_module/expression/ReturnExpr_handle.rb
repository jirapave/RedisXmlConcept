require_relative "expression_module"
require_relative "expression_handle"

module XQuery
  module ExpressionModule
    class ReturnExprHandle < ExpressionHandle
      
      attr_reader :value
      
      def initialize(node)
        super(node)
        
        #TODO delete
        puts "initializing ReturnExpr"
        #TODO delete
        
        puts "node: #{node.name}"
        
        reduced = ExpressionModule::reduce(node)
        if(reduced.name == RelativePathExpr)
          @value = RelativePathExprHandle.new(reduced)
        else
          raise StandardError, "not implemented other type of return expression then RelativePath: #{reduced.name}"
        end
        
      end
      
      def type
        ReturnExpr
      end
      
    end
  end
end