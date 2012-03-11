module XQuery
  module ExpressionModule
    class DummyExpressionHandle
      
      attr_reader :type, :text
      
      def initialize(type, content)
        @type = type
        @text = content
      end

      def parts
        []
      end
      
    end
  end
end