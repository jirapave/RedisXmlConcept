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
        
        @parts = []
        reduced = ExpressionModule::reduce(node)
        case reduced.name
          
          
        when RelativePathExpr
          @parts << RelativePathExprHandle.new(reduced)
          
          
        when VarRef
          @parts << VarRefHandle.new(reduced)
          
          
        when DirElemConstructor
          @parts << DirElemConstructorHandle.new(reduced)
          
        when DeleteExpr
          @parts << DeleteExprHandle.new(reduced)
          
        when InsertExpr
          @parts << InsertExprHandle.new(reduced)
          
          
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