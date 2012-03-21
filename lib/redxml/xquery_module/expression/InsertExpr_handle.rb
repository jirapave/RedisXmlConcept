require_relative "expression_module"
require_relative "expression_handle"

module XQuery
  module ExpressionModule
    class InsertExprHandle < ExpressionHandle
      
      TARGET_INTO_LAST = :TARGET_INTO_LAST
      TARGET_INTO_FIRST = :TARGET_INTO_FIRST
      TARGET_BEFORE = :TARGET_BEFORE
      TARGET_AFTER = :TARGET_AFTER
      
      attr_reader :items, :location
      
      def initialize(node)
        super(node)
        
        #TODO delete
        puts "initializing InitializeExpr"
        #TODO delete
        
        items_node = node.children[2]
        location_node = node.children[4]
        target_choice = nil
        
        #determine which one
        case node.children[3].content
        when "into", "aslastinto"
          target_choice = TARGET_INTO_LAST
        when "asfirstinto"
          target_choice = TARGET_INTO_FIRST
        when "before"
          target_choice = TARGET_BEFORE
        when "after"
          target_choice = TARGET_AFTER
        else
          raise StandardError, "impossible"
        end
        
        
        @items = determine_expression(items_node)
        @location = determine_expression(location_node)
        
      end
      
      
      def determine_expression(node)
        expr = nil
        reduced_node = ExpressionModule::reduce(node) #should give RelativePathExpr - typically
        case reduced_node.name
        when RelativePathExpr
          expr = RelativePathExprHandle.new(reduced_node)
        when VarRef
          expr = VarRefHandle.new(reduced_node)
        else
          raise NotSupportedError, reduced_node.name
        end
        return expr
      end
      
      
    end
  end
end