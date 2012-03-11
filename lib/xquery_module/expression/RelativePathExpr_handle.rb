require_relative "expression_module"
require_relative "expression_handle"
require_relative "StepExpr_handle"

module XQuery
  module ExpressionModule 
    class RelativePathExprHandle < ExpressionHandle #encapsulates Steps

      attr_reader :steps

      
      def initialize(node)
        super(node)
        
        #TODO delete
        puts "initializing RelativePathExpr"
        #TODO delete
        
        @steps = []
        
        #parse steps and remember // or /
        step_type = StepExprHandle::STARTING
        node.children.each { |child|
          if(child.name == "TOKEN")
            case child.content
            when "/"
              step_type = StepExprHandle::ORDINARY
            when "//"
              step_type = StepExprHandle::RECURSIVE
            else
              raise StandardError, "impossible, token is #{child.content}"
            end
            
          else
            @steps << StepExprHandle.new(child, step_type)
            
          end
        }
        
      end
      
    end
  end
end