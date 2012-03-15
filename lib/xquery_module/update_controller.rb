require_relative "solver/xquery_solver"
require_relative "exceptions"
require_relative "query_parser"

module XQuery
  class UpdateController
    
    def initialize(environment, collection)
      @xquery_solver = XQuerySolver.new(environment, collection)
    end
    
    def get_results(query)
      
      #parse query into Expression object
      expression = QueryParser.parse_update(query)
      
      #solve parsed expression
      return @xquery_solver.solve(expression)
      
    end
    
  end
end