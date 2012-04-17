require_relative "flwor_solver"
require_relative "path_solver"
require_relative "delete_solver"
require_relative "insert_solver"
require_relative "../expression/expression_module"
require_relative "../../transformer/key_builder"
require_relative "../../transformer/key_element_builder"

module XQuery
  class UpdateSolver
    
    def initialize(path_solver)
      @path_solver = path_solver
      @delete_solver = DeleteSolver.new(@path_solver)
      @insert_solver = InsertSolver.new(@path_solver)
    end
    
    def solve(expression, context=XQuerySolverContext.new, pipelined=true)
      case expression.type
      when ExpressionModule::DeleteExpr
        @delete_solver.solve(expression, context, pipelined)
      when ExpressionModule::InsertExpr
        @insert_solver.solve(expression, context, pipelined)
        
      else
        raise StandardError, "not implemented #{expression.type}"
      end
    end
    
  end
end