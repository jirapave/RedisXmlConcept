require_relative "expression_module"
require_relative "expression_handle"

module XQuery
  module ExpressionModule
    class ReturnExprHandle < ExpressionHandle
      
      
      class ReturnTextHandle
        attr_reader :type, :text
        def initialize(text)
          @type = ReturnText
          @text = text
        end
      end
      
      
      
      attr_reader :parts
      
      def initialize(node)
        super(node)
        
        #TODO delete
        puts "initializing ReturnExpr"
        #TODO delete
        
        puts "node: #{node.name}"
        
        @parts = []
        reduced = ExpressionModule::reduce(node)
        case reduced.name
          
          
        when RelativePathExpr
          @parts << RelativePathExprHandle.new(reduced)
          
          
        when VarRef
          @parts << VarRefHandle.new(reduced)
          
          
        when DirElemConstructor
          path_expr = ""
          return_text = ""
          reduced.children.each { |child|
            if(child.name == DirElemContent)
              if(!return_text.empty?)
                @parts << ReturnTextHandle.new(return_text)
                return_text = ""
              end
              path_expr << child.content
            else
              if(!path_expr.empty?)
                @parts << XQuery::QueryParser.parse_xquery(path_expr)
                path_expr = ""
              end
              return_text << child.content
            end
          }
          
          if(!return_text.empty?)
            @parts << ReturnTextHandle.new(return_text)
            return_text = ""
          elsif(!path_expr.empty?)
            @parts << XQuery::QueryParser.parse_query(path_expr)
            path_expr = ""
          end
          
          
        when DeleteExpr
          @parts << DeleteExprHandle.new(reduced)
          
          
        else
          raise NotSupportedError, reduced.name
        end
      end
      
      def type
        ReturnExpr
      end
      
    end
  end
end