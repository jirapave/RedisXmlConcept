require_relative "flwor_solver"
require_relative "path_solver"
require_relative "../expression/expression_module"
require_relative "../../transformer/key_builder"
require_relative "../../transformer/key_element_builder"

module XQuery
  class XQuerySolver
    
    def initialize(environment, collection)
      @path_solver = PathSolver.new(environment, collection)
      @update_solver = UpdateSolver.new(@path_solver)
      @flwor_solver = FLWORSolver.new(@path_solver, @update_solver)
    end
    
    def solve(expression)
      case expression.type
      when ExpressionModule::FLWORExpr
        results = @flwor_solver.solve(expression)
        return prepare_results(results)
        
      when ExpressionModule::RelativePathExpr
        results = @path_solver.solve(expression) 
        return prepare_results(results)
        
      #simple update queries
      when ExpressionModule::DeleteExpr, ExpressionModule::InsertExpr
        @update_solver.solve(expression)
        
      else
        raise StandardError, "not implemented #{expression.type}"
      end
    end
    
  private
    def prepare_results(results)
      final_results = []
      results.each { |result|
        if(result.kind_of?(ExtendedKey))
          final_results << @path_solver.path_processor.get_node(result)
        else
          final_results << result
        end
      }
      
      #TODO delete this debug print
      # puts "XQuerySolver: FINAL results"
      # final_results.each { |f|
        # puts f
      # }
      return final_results
    end
    
  end
end