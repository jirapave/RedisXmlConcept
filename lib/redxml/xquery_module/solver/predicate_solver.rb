require_relative "comparison_solver"
require_relative "../expression/expression_module"
require_relative "../expression/dummy_expression_handle"
require_relative "../expression/AbbrevForwardStep_handle"


module XQuery
  class PredicateSolver
    
    def initialize(path_processor)
      @path_processor = path_processor
    end
    
    #it assumes that predicate_expressions are in array, even if only one provided
    def evaluate(predicate_expressions, actual_result, position, max_position)
      
      predicate_expressions.each { |predicate|
        if(!evaluate_predicate(predicate, actual_result, position, max_position))
          return false
        end
      }
      
      return true
    end
    
    
    
  private
    def evaluate_predicate(predicate_expression, actual_result, position, max_position)#returns true or false
      
      predicate = predicate_expression.value
      
      case predicate.type
      ######################
      # Comparison handling
      ######################
      when ExpressionModule::ComparisonExpr
        values1 = get_predicate_values(predicate.value1, actual_result, position, max_position)
        operator = predicate.operator
        values2 = get_predicate_values(predicate.value2, actual_result, position, max_position)
        #value1 and value2 are always arrays - even with only one participant
        return ComparisonSolver.evaluate(values1, operator, values2)
        
      
      ######################
      # Element or Attribute exists handling
      ######################  
      when ExpressionModule::AbbrevForwardStep
        puts "solving predicate"
        if(predicate.value_type == ExpressionModule::AbbrevForwardStepHandle::ELEMENT)
          res = @path_processor.get_children_elements(actual_result, predicate.value_name)
          if(res.empty?)
            return false
          end
          puts "----RETURNING true"
          
        elsif(predicate.value_type == ExpressionModule::AbbrevForwardStepHandle::ATTRIBUTE)
          if(!@path_processor.get_attribute(actual_result, predicate.value_name))
            return false
          end
          
        else
          raise StandardError, "impossible"
        end
        return true


      ######################
      # Single function handling
      ######################        
      when ExpressionModule::FunctionCall
        if(predicate.function_name == "last" && predicate.function_params.empty?)
          return position == max_position
        elsif(predicate.function_name == "position" && predicate.function_params.empty?)
          return true
        else
          raise StandardError, "not implemented"
        end
        
        
      ######################
      # Integer handling
      ######################        
      when ExpressionModule::IntegerLiteral
        return predicate.text.to_i == position
        
      end
    end
    
    
    def get_predicate_values(expression, actual_result, position, max_position)
      case expression.type
      when ExpressionModule::FunctionCall
        #we support only functions 'last' and 'position' for now
        if(expression.function_name == "last" && expression.function_params.empty?)
          return [ ExpressionModule::DummyExpressionHandle.new(ExpressionModule::NumericLiteral, max_position) ] #returning numeric
        elsif(expression.function_name == "position" && expression.function_params.empty?)
          return [ ExpressionModule::DummyExpressionHandle.new(ExpressionModule::NumericLiteral, position) ] #returning numeric
        else
          raise StandardError, "not implemented function #{expression.function_name}"
        end
        
      when ExpressionModule::ContextItemExpr
        if(expression.text != ".")
          raise StandardError, "other ContextItemExpr.content not supported: #{expression.content}"
        end
        #returning string
        return [ ExpressionModule::DummyExpressionHandle.new(ExpressionModule::StringLiteral, @path_processor.get_node_content(actual_result)) ]
        
        
      when ExpressionModule::AbbrevForwardStep
        if(!@path_processor.valid_elem?(actual_result))
          raise QueryStringError, "after text resulting step cannot be predicate of this format"
        end
        
        results = []
        if(expression.value_type == ExpressionModule::AbbrevForwardStepHandle::ELEMENT)
          res = @path_processor.get_children_elements(actual_result, expression.value_name)
          res.each { |r|
            results << @path_processor.get_node_content(r)
          }
          
        elsif(expression.value_type == ExpressionModule::AbbrevForwardStepHandle::ATTRIBUTE)
          results = [ @path_processor.get_attribute(actual_result, expression.value_name) ]
          
        else
          raise StandardError, "impossible"
        end
        
        typed_results = []
        results.each { |res|
          typed_results << ExpressionModule::DummyExpressionHandle.new(ExpressionModule::StringLiteral, res) #returning string
        }
        return typed_results
        
      #String and Numeric literals return as are - literal objects, so it is recognisable the type
      when ExpressionModule::NumericLiteral
        #returning numeric
        return [ expression ]
         
      when ExpressionModule::StringLiteral
        #returning string
        return [ ExpressionModule::DummyExpressionHandle.new(ExpressionModule::StringLiteral, expression.text.gsub("'", "").gsub('"', "")) ]
         
      else
        raise StandardError, "other types of predicate values are not supported yet: #{expression.type}"
        
      end
    end
      
    
    
  end
end