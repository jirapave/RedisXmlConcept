module XQuery
  module ExpressionModule
    class ExpressionHandle
      
        def initialize(node)
          @node = node
          
          #TODO delete
          # puts "initializing #{type}"
          #TODO delete
        end

        def type
          return @node.name
        end
        
        def text
          @node.content
        end
      
    end
  end
end