require_relative "flwor_solver"
require_relative "path_solver"
require_relative "delete_solver"
require_relative "../expression/expression_module"
require_relative "../../transformer/key_builder"
require_relative "../../transformer/key_element_builder"

module XQuery
  class UpdateSolver
    
    def initialize(environment, collection)
      @path_solver = PathSolver.new(environment, collection)
      @flwor_solver = FLWORSolver.new(@path_solver)
      @delete_solver = DeleteSolver.new(@path_solver)
    end
    
    def solve(expression)
      case expression.type
      when ExpressionModule::FLWORExpr
        @flwor_solver.solve(expression)
        
      when ExpressionModule::DeleteExpr
        @delete_solver.solve(expression) 
        
      else
        raise StandardError, "not implemented #{expression.type}"
      end
    end
    
  end
end