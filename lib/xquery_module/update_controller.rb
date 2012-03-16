require_relative "solver/update_solver"
require_relative "exceptions"
require_relative "query_parser"

module XQuery
  class UpdateController
    
    def initialize(environment, collection)
      @update_solver = UpdateSolver.new(environment, collection)
    end
    
    def perform(query)
      
      #parse query into Expression object
      expression = QueryParser.parse_update(query)
      
      #solve parsed expression
      @update_solver.solve(expression)
      
    end
    
  end
end