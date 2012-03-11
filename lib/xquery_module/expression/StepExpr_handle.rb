require_relative "expression_module"
require_relative "expression_handle"
require_relative "VarRef_handle"
require_relative "FunctionCall_handle"
require_relative "AbbrevForwardStep_handle"
require_relative "Predicate_handle"

module XQuery
  module ExpressionModule 
    class StepExprHandle < ExpressionHandle #encapsulates some functions, elements
      
      attr_reader :step_type, :value, :predicates
      
      #step type
      ORDINARY = :ORDINARY
      RECURSIVE = :RECURSIVE
      STARTING = :STARTING
      
      def initialize(node, step_type=START)
        super(node)
        
        #TODO delete
        puts "initializing StepExpr"
        #TODO delete
        
        @step_type = step_type
        
        @value = nil
        @predicates = []
        
        #determine specific step type
        sub_node = node.children[0]
        sub_node.children.each { |child|
          case child.name
            
          when "#{PrimaryExpr}" #this will probably be a function or variable
            reduced_node = ExpressionModule::reduce(child)
            if(reduced_node.name == "#{VarRef}")
              @value = VarRefHandle.new(reduced_node)
            elsif(reduced_node.name == "#{FunctionCall}")
              @value = FunctionCallHandle.new(reduced_node)
            else
              raise StandardError, "not implemented"
            end
            
            
          when "#{ForwardStep}"
            if(child.children[0].name != "#{AbbrevForwardStep}")
              raise StandardError, "not implemented"
            end
            @value = AbbrevForwardStepHandle.new(child.children[0]) #probably AbbrevForwardStep - element or attribute name
            
            
          when "#{PredicateList}"
            child.children.each { |pred|
              @predicates << PredicateHandle.new(pred)
            }
            
            
          else
            raise StandardError, "not implemented: #{child.name}"
          end
        }
        
      end
      
    end
  end
end