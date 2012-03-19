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
        reduced_node = ExpressionModule::reduce(location_node) #should give RelativePathExpr - typically
        
        case reduced_node.name
        when RelativePathExpr
          @location = RelativePathExprHandle.new(reduced_node)
        when VarRef
          @location = VarRefHandle.new(reduced_node)
        else
          raise NotSupportedError, @location.name
        end
        
        
      end
      
      
    end
  end
end