require_relative "expression_module"
require_relative "expression_handle"

module XQuery
  module ExpressionModule
    class ForLetClauseHandle < ExpressionHandle
      
      attr_reader :parts
      
      #each for clause can contain more than one ($var in path) parts
      class Part
        
        attr_reader :var_name, :path_expr
        
        def initialize(var_name, path_expr)
          @var_name = var_name
          @path_expr = path_expr
        end
      end
      
      
      def initialize(node)
        super(node)
        
        #generate parts
        @parts = []
        var_node_set = node.xpath("./VarName")
        path_node_set = node.xpath("./ExprSingle")
        var_node_set.each_with_index { |var, index|
          reduced = ExpressionModule::reduce(path_node_set[index])
          if(reduced.name != RelativePathExpr)
            raise StandardError, "other type not supported: #{reduced.name}"
          end
          @parts << Part.new(var.content, RelativePathExprHandle.new(reduced))
        }
      end
      
      
    end
  end
end