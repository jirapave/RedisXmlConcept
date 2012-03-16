require_relative "expression_module"
require_relative "expression_handle"

module XQuery
  module ExpressionModule
    class OrderByClauseHandle < ExpressionHandle
      
      
      class OrderSpec
        
        attr_reader :expr, :modifier
                                   #string
        def initialize(order_expr, order_modifier)
          @expr = order_expr
          @modifier = order_modifier
        end
        
      end
      
      
      attr_reader :parts
      
      def initialize(node)
        super(node)
        
        #TODO delete
        puts "initializing OrderByClause"
        #TODO delete
        
        #generate parts
        @parts = []
        order_spec_list = node.children[2]
        order_spec_list.children.each { |order_spec|
          
          modifier = order_spec.children[1].content
          if(!modifier.empty?)
            if(modifier != "ascending" && modifier != "descending")
              raise StandardError, "other order modifier than ascending/descending not supported: #{modifier}"
            end
          end
          
          reduced_order = ExpressionModule::reduce(order_spec.children[0])
          case reduced_order.name
          when RelativePathExpr
            @parts << OrderSpec.new(RelativePathExprHandle.new(reduced_order), modifier)
          when VarRef
            @parts << OrderSpec.new(VarRefHandle.new(reduced_order), modifier)
          else
            raise StandardError, "other order expr then RelativePathExpr not supported: #{reduced_order.name}"
          end
        }
      end
      
    end
  end
end