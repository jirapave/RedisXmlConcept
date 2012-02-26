require_relative "xquery_solver"
require_relative "../exceptions"
require_relative "xquery_parser"

module XQuery
  class XQueryController
    
    def initialize(environment, collection)
      @xquery_solver = XQuerySolver.new(environment, collection)
    end
    
    def get_results(query)
      
      #parse query into Expression object
      expression = XQueryParser.parse_query(query)
      
      #solve parsed expression
      return @xquery_solver.get_results(expression)
      
    end
    
    
    
  end
end