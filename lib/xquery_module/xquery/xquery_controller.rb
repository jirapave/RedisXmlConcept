require_relative "xquery_solver"
require_relative "../exceptions"
require_relative "xquery_parser"

module XQuery
  class XQueryController
    
    def initialize(database, collection)
      @xquery_solver = XQuerySolver.new(database, collection)
    end
    
    def get_results(query)
      
      #parse query into Expression object
      expression = XQueryParser.parse_query(query)
      
      #solve parsed expression
      return @xquery_solver.get_results(expression)
      
      # assume only xpath query for now
      # @xpath.get_results(query)
      
    end
    
    
    
  end
end