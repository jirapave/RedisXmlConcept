require_relative "expression_module"
require_relative "expression_handle"
require_relative "ComparisonExpr_handle"
require_relative "FunctionCall_handle"

module XQuery
  module ExpressionModule 
    class PredicateHandle < ExpressionHandle
      
      attr_reader :value
      
      
      def initialize(node)
        super(node)
        
        #TODO delete
        puts "initializing Predicate"
        #TODO delete
        
        #TODO determine predicate type
        #supported so far: single and tripple
        #single value: last(), 1, 2, ...
        #tripple: comparison
        
        
        #we suppose, that predicate consists of '[' Expr ']' - so children[1] is our choice
        if(node.children.length != 3)
          raise StandardError, "other children length (node.children.length) than 3 not supported"
        end
        @value = get_value(ExpressionModule::reduce(node.children[1]))
        
        
      end
      
    private
      def get_value(node)
        case node.name
        when "#{ComparisonExpr}"
          return ComparisonExprHandle.new(node)
          
        when "#{FunctionCall}"
          return FunctionCallHandle.new(node)
          
        when "#{IntegerLiteral}"
          return ExpressionHandle.new(node)
          
        else
          raise StandardError, "another predicate type not implemented (#{node.parent.name}), content #{node.content}"
        end
      end
      
      
    end
  end
end