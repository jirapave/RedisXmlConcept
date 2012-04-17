require_relative "function_solver"
require_relative "predicate_solver"
require_relative "xquery_solver_context"
require_relative "../processor/key_path_processor"
require_relative "../exceptions"
require_relative "../expression/expression_module"
require_relative "../expression/AbbrevForwardStep_handle"
require_relative "../expression/StepExpr_handle"


module XQuery
  class PathSolver
    
    attr_reader :path_processor
    
    def initialize(environment, collection)
      @function_solver = FunctionSolver.new(environment, collection)
    end
    
    def solve(path_expr, context=XQuerySolverContext.new) #returns keys or nodes, DOESN'T change context
      #here is nothing to cycle, solved in FLWOR solvers only
      
      #TODO delete
      # puts "PATH solver, step count: #{path_expr.steps.length}"
      
      @path_processor = nil
      @last_step = false
      
      #TODO we need to grab each step and sequentially take care of it
      results = [] #results are prepared nodes with all data or KeyElementBuilders
      path_expr.steps.each { |step|
        
        #debug TODO delete
        puts "step, type: #{step.step_type}, content: #{step.text}"
        #debug TODO delete
         
        if(step.step_type == ExpressionModule::StepExprHandle::STARTING)
          results = solve_step(step, context)
        elsif(results.empty?)
          return []
        else
          new_results = []
          results.each_with_index { |res, index|
            if(@last_step && index > 0)
              @last_step = false
            end
            new_results.concat(solve_step(step, context, res))
          }
          results = new_results
        end
        
        #debug TODO delete
        # puts "===>STEP RESULTS start"
        # results.each { |res|
          # puts res.inspect
        # }
        # puts "===<STEP RESULTS end"
        #debug TODO delete
        
      }
      
      #debug TODO delete
      # puts "Path Solver RETURNING: "
      # puts "===>STEP RESULTS start"
      # results.each { |res|
        # puts res.inspect
      # }
      # puts "===<STEP RESULTS end"
      #debug TODO delete
      
      return results
    end
    
    
  private
    def solve_step(step_expression, context, actual_result=nil)#returns results
      
      if(@last_step)
        raise QueryStringError, "previous step was already finalizing, actual step: #{step_expression.value.type}, content: #{step_expression.value.text}"
      end
      
      specified_step = step_expression.value
      predicates = step_expression.predicates
      
      
      ################
      # FIRST step
      ################
      if(actual_result == nil)
        #here is allowed only doc FunctionCall or VarRef
        case specified_step.type
        when ExpressionModule::FunctionCall
          parameters = specified_step.function_params
          if(specified_step.function_name == "doc" && parameters.length == 1 && parameters[0].type == ExpressionModule::StringLiteral)
            key_builder = @function_solver.doc(parameters[0].value)
            @path_processor = KeyPathProcessor.new(key_builder)
          else
            raise QueryStringError, "other function then doc with 1 string parameter is not allowed, here we have: #{specified_step.function_name}(#{parameters.length} params, type(1):#{parameters[0].type})" 
          end
          
          return [ ExtendedKey.new(key_builder) ]
          #probably no need to solve predicates
          
          
        when ExpressionModule::VarRef
          node = context.variables[specified_step.var_name]
          if(node == nil)
            raise QueryStringError, "such variable (#{specified_step.var_name}) not found in current context"
          end
          
          @path_processor = KeyPathProcessor.new(node.key_builder)
          
          
          #maybe predicates?
          if(!predicates.empty?)
            #solve predicates
            predicate_solver = PredicateSolver.new(@path_processor)
            predicates_result = predicate_solver.evaluate(predicates, node, 1, 1)
            if(!predicates_result)
              return []
            end
          end
          
          return [ node ]
          
        end
        
        
        
      ################
      # NEXT step
      ################  
      else
        case specified_step.type
        when ExpressionModule::AbbrevForwardStep  #element or attribute
          
          case specified_step.value_type
          when ExpressionModule::AbbrevForwardStepHandle::ELEMENT
            ### results setting
            # puts "element" TODO delete
            results = get_child_elements(actual_result, specified_step.value_name, step_expression.step_type)

            
          when ExpressionModule::AbbrevForwardStepHandle::ATTRIBUTE
            # puts "attr" TODO delete
            @last_step = true
            case step_expression.step_type
            when ExpressionModule::StepExprHandle::ORDINARY
              ### results setting
              results =  [ @path_processor.get_attribute(actual_result, specified_step.value_name) ]
            when ExpressionModule::StepExprHandle::RECURSIVE
              ### results setting
              results = get_attributes_recursively(actual_result, specified_step.value_name)
            else
              raise StandardError, "impossible, abbrevforward ATTRIBUTE, value name: #{specified_step.value_name}"
            end
            
            
          when ExpressionModule::AbbrevForwardStepHandle::TEXT
            # puts "text" TODO delete
            @last_step = true
            case step_expression.step_type
            when ExpressionModule::StepExprHandle::ORDINARY
              ### results setting
              results =  [ @path_processor.get_text(actual_result) ]
            when ExpressionModule::StepExprHandle::RECURSIVE
              ### results setting
              results = @path_processor.get_descendant_texts(actual_result)
            else
              raise StandardError, "impossible, abbrevforward ATTRIBUTE, value name: #{specified_step.value_name}"
            end
            
          end
          
          
        when ExpressionModule::FunctionCall
          @last_step = true
          #only text() supported
          if(specified_step.function_name == "text" && specified_step.function_params.empty?)
            ### results setting
            results = @path_processor.get_texts(actual_result)
          else
            raise StandardError, "other function not implemented"
          end
          
          
        else
          raise StandardError, "other type of specified step not implemented: #{specified_step.type}"
          
          
        end
        
        
        
        
        #remove nils
        temp_results = results
        results = []
        temp_results.each { |res|
          results << res if(res != nil)
        }
        
        #check if predicates exist
        if(predicates.empty?)
          return results
        end
        
        #predicate solving for NEXT steps
        final_results = []
        results_size = results.length 
        results.each_with_index { |res, index|
          predicate_solver = PredicateSolver.new(@path_processor)
          predicates_result = predicate_solver.evaluate(predicates, res, index+1, results_size)
          #TODO TODO TODO review - this must be wrong, is predicate solver prepared for all kinds of results? (especially texts?)
          if(predicates_result)
            final_results << res
          end 
        }
        
        
        
        return final_results
        
      end
      
      
      
    end
    
    
    
    def get_child_elements(actual_result, elem_name, step_type)
      case step_type
      when ExpressionModule::StepExprHandle::ORDINARY
        return @path_processor.get_children_elements(actual_result, elem_name)
      when ExpressionModule::StepExprHandle::RECURSIVE
        return @path_processor.get_descendant_elements(actual_result, elem_name)
      else
        raise StandardError, "impossible"
      end
    end
    
    def get_attributes_recursively(actual_result, attr_name)
      attributes = []
      elements = @path_processor.get_descendant_elements(actual_result)
      elements.each { |elem|
        attributes << @path_processor.get_attribute(elem, attr_name)
      }
      return attributes
    end
    
    
  end
end