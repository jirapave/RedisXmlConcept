require_relative "xquery_solver"
require_relative "query_string_error"
require_relative "xquery_parser"

module XQuery
  class XQueryController
    
    def initialize(database, collection)
      @xquery_solver = XQuerySolver.new(database, collection)
    end
    
    def get_results(query)
      
      #TODO parse query
      expression = XQueryParser.parse_query(query)
      
      #solve parsed expression
      @xquery_solver.get_results(expression)
      
      # assume only xpath query for now
      # @xpath.get_results(query)
      
    end
    
    
    
  end
end