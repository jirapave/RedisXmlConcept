require_relative "expression_module"
require_relative "expression_handle"

module XQuery
  module ExpressionModule
    class FunctionCallHandle < ExpressionHandle
      
      class FunctionParam

        attr_reader :value, :type
                
        #types
        StringLiteral = :StringLiteral
        IntegerLiteral = :IntegerLiteral
        #types 
        
        def initialize(value, type)
          @value = value
          @type = type
        end
      end
      
      
      
      attr_reader :function_name, :function_params
      
      def initialize(node)
        super(node)
        
        @function_name = node.xpath("./FunctionName")[0].content
        @function_params = []
        node.xpath("./ExprSingle").each { |expr|
          reduced = ExpressionModule::reduce(expr)
          param_content = reduced.content
          if(param_content.match(/\A["'].*["']\Z/))
            param_content = param_content.gsub("'", "").gsub('"', '')
          end 
          @function_params << FunctionParam.new(param_content, reduced.name)
        }
      end
      
    end
  end
end