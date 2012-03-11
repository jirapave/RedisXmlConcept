require_relative "expression_module"
require_relative "expression_handle"
require_relative "AbbrevForwardStep_handle"
require_relative "FunctionCall_handle"

module XQuery
  module ExpressionModule 
    class ComparisonExprHandle < ExpressionHandle
      
      
      attr_reader :value1, :operator, :value2
      
      def initialize(node)
        super(node)
        
        #TODO delete
        puts "initializing ComparisonExpr"
        #TODO delete
        
        if(node.children.length != 3)
          raise StandardError, "wrong number of values in Comparison - #{node.children.length}"
        end
        
        @value1 = get_value(node.children[0]) # can be AbbrevForwardStep or some kind of literal
        @operator = get_operator(node.children[1])
        @value2 = get_value(node.children[2]) # can be AbbrevForwardStep or some kind of literal
      end
      
    private
      def get_value(node)
        val = ExpressionModule::checked_reduce(node, AbbrevForwardStep) #we don't count on predicates here
        case val.name
          
        when DoubleLiteral, DecimalLiteral, IntegerLiteral
          val = val.parent
          return ExpressionHandle.new(val) #NumericLiteral

          
        when AbbrevForwardStep
          return AbbrevForwardStepHandle.new(val)
        
        when RelativePathExpr
          return RelativePathExprHandle.new(val)  
          
        when StringLiteral
          return ExpressionHandle.new(val)
          
        when FunctionCall
          return FunctionCallHandle.new(val)
          
        when "TOKEN"
          return ExpressionHandle.new(val.parent) #probably ContextItemExpr
          
        else
          raise StandardError, "this type of value (#{val.name}) is not supported as comparison parameter"
        end
      end
      
      def get_operator(node)
        op = ExpressionModule::reduce(node)
        if(op.name == "TOKEN")
          op = op.parent
          return ExpressionHandle.new(op)
        else
          raise StandardError, "this type of operator (#{val.name}) is not supported as comparison operator"
        end
      end 
      
    end
  end
end