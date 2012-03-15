require_relative "expression_module"
require_relative "expression_handle"

module XQuery
  module ExpressionModule
    class DeleteExprHandle < ExpressionHandle
      
      attr_reader :location
      
      def initialize(node)
        super(node)
        
        #TODO delete
        puts "initializing DeleteExpr"
        #TODO delete
        
        location_node = node.children[2]
        @location = ExpressionModule::reduce(node) #should give RelativePathExpr - typically
        
      end
      
      
    end
  end
end