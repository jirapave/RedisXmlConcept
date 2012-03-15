require_relative "expression_module"
require_relative "expression_handle"
require_relative "ForLetClause_handle"
require_relative "WhereClause_handle"
require_relative "OrderByClause_handle"
require_relative "ReturnExpr_handle"

module XQuery
  module ExpressionModule
    class FLWORExprHandle < ExpressionHandle
      
      def initialize(node)
        super(node)
        
        #TODO delete
        puts "initializing FLWOR"
        #TODO delete
        
        #scan for clauses and prepare parts this time
        @children = []
        was_return = false
        puts "children count: #{node.children.length}"
        node.children.each { |child|
          puts "child name: #{child.name}, child content: #{child.content}"
          if(child.name == "TOKEN" && child.content == "return")
            was_return = true
            next
          end
          if(!was_return)
            case child.name
            when ForClause, LetClause
              @children << ForLetClauseHandle.new(child)
            when WhereClause
              @children << WhereClauseHandle.new(child)
            when OrderByClause
              @children << OrderByClauseHandle.new(child)
            else
              raise StandardError, "such FLWOR expression not recognised: #{child.name}"
            end
          else
            @children << ReturnExprHandle.new(child)
          end
        }
        
      end
      
      def parts
        @children
      end
      
    end
  end
end