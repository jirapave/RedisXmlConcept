require_relative "update_solver"

module XQuery
  class ReturnExprSolver
    
    def initialize(path_solver, update_solver)
      @path_solver = path_solver
      @update_solver = update_solver
    end
    
    def solve(return_expr, contexts)
      
      results = []
      delete = false
      
      add_result = Proc.new { |context|
        #compose result
        result = ""
        return_expr.parts.each { |part|
          case part.type
          when ExpressionModule::ReturnText
            result << part.text
            
          when ExpressionModule::RelativePathExpr, ExpressionModule::VarRef
            ext_keys = []
            if(part.type == ExpressionModule::RelativePathExpr)
              ext_keys = @path_solver.solve(part, context)
            else
              ext_keys = context.variables[part.var_name]
            end
            path_result = ""
            if(ext_keys)
              ext_keys.each { |key|
                path_result << @path_solver.path_processor.get_node(key).to_s
              }
            end
            result << path_result
            
          when ExpressionModule::DirElemConstructor
            result << part.get_elem_str(@path_solver, context)
            
          when ExpressionModule::DeleteExpr, ExpressionModule::InsertExpr #and other
            raise StandardError, "update expressions should be performed another way -> atomically"
            
          else
            raise NotSupportedError, part.type
            
          end
        }
        results << result
      }
      
      #declare contexts
      final_contexts = []
      
      if(contexts.length > 0 && contexts[0].order == -1)
        final_contexts = contexts
      else
        sorting_hash = Hash.new
        contexts.each_with_index { |context, index|
          sorting_hash[context.order] = index
        }
        sorting_hash.keys.sort.each { |sort_key|
          
          context = contexts[sorting_hash[sort_key]]
          
          final_contexts << context
        }
      end
      
      
      first_part = return_expr.parts[0]
      if(first_part.type == ExpressionModule::DeleteExpr \
          || first_part.type == ExpressionModule::InsertExpr)
         
        if(return_expr.parts.length > 1)
          raise NotImplementedError, "more update expressions within one query not implemented"
        end
        
        #update operations will take care of their own pipelining
        
        #performing update here, sending all contexts
        @update_solver.solve(first_part, final_contexts, true)
        
        
      else
        #perform all other operations (non-update ones) here
        db = BaseInterface::DBInterface.instance
        db.pipelined do
          final_contexts.each { |context|
            add_result.call(context)
          }
        end #end of pipelined
      end
      
      return results      
    end
    
  end
end