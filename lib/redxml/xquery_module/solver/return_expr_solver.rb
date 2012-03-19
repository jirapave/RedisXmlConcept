require_relative "update_solver"

module XQuery
  class ReturnExprSolver
    
    def initialize(path_solver, update_solver)
      @path_solver = path_solver
      @update_solver = update_solver
    end
    
    def solve(return_expr, contexts)
      puts "solving #{return_expr.type}"
      puts "return_expr.parts.length: #{return_expr.parts.length}"
      
      results = []
      delete = false
      
      add_result = Proc.new { |context|
        #compose result
        result = ""
        return_expr.parts.each { |part|
          case part.type
          when ExpressionModule::ReturnText
            result << part.text
          when ExpressionModule::RelativePathExpr
            #should return only one value
            path_result = @path_solver.solve(part, context)[0]
            if(!path_result.kind_of?(String))
              path_result = @path_solver.path_processor.get_node(path_result).to_s #TODO do it differently - to return node
            end
            result << path_result
          when ExpressionModule::VarRef
            #should return only one value
            result << @path_solver.path_processor.get_node(context.variables[part.var_name]).to_s
            
          when ExpressionModule::DeleteExpr #and other
            puts "delete expr"
            @update_solver.solve(part, context, false)
            
          else
            raise NotSupportedError, part.type
            
          end
        }
        results << result
      }
      
      db = BaseInterface::DBInterface.instance
      db.pipelined do
        puts "pipelined..., contexts.length: #{contexts.length}"
        if(contexts.length > 0 && contexts[0].order == -1)
          puts "non-ordered"
          contexts.each { |context|
            puts "one context"
            add_result.call(context)
          }
        else
          sorting_hash = Hash.new
          contexts.each_with_index { |context, index|
            sorting_hash[context.order] = index
          }
          sorting_hash.keys.sort.each { |sort_key|
            
            context = contexts[sorting_hash[sort_key]]
            puts "RETURNING according order: #{context.order}"
            
            add_result.call(context)
          }
        end
      end
      
      
      return results      
    end
    
  end
end