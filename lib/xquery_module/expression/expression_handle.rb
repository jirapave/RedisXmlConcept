module XQuery
  module ExpressionModule
    class ExpressionHandle
      
        def initialize(node)
          @node = node
        end

        def type
          return @node.name
        end
        
        # def parts #DEPRICATED shouldnt be used...
          # puts "DEPRICATED call of expression_module.parts, shouldnt be called"
          # parts = []
          # @node.children { |child|
            # parts << create_expr(child)
          # }
          # return parts
        # end
        
        def text
          @node.content
        end
      
    end
  end
end