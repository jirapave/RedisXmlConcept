require_relative "expression_module"
require_relative "expression_handle"
require_relative "CompAttrConstructor_handle"
require_relative "ElemConstructor_handle"
require_relative "dummy_expression_handle"

module XQuery
  module ExpressionModule
    class InsertExprHandle < ExpressionHandle
      
      TARGET_INTO_LAST = :TARGET_INTO_LAST
      TARGET_INTO = :TARGET_INTO_LAST
      TARGET_INTO_FIRST = :TARGET_INTO_FIRST
      TARGET_BEFORE = :TARGET_BEFORE
      TARGET_AFTER = :TARGET_AFTER
      
      attr_reader :items, :location, :target_choice
      
      def initialize(node)
        super(node)
        
        #TODO delete
        puts "initializing InsertExpr"
        #TODO delete
        
        items_node = node.children[2]
        location_node = node.children[4]
        @target_choice = nil
        
        #determine which one
        case node.children[3].content
        when "into", "aslastinto"
          @target_choice = TARGET_INTO_LAST
        when "asfirstinto"
          @target_choice = TARGET_INTO_FIRST
        when "before"
          @target_choice = TARGET_BEFORE
        when "after"
          @target_choice = TARGET_AFTER
        else
          raise StandardError, "impossible"
        end
        
        
        #can be more then one, attribute, variable with some nodes, node from documents in database,
        #new nodes and text
        @items = determine_expression(items_node)
        if(!@items.kind_of?(Array))
          @items = [ @items ]
        end
        @location = determine_expression(location_node) #can be only one, location in a document
        
      end
      
      
      def determine_expression(node)
        expr = nil
        reduced_node = ExpressionModule::reduce(node) #should give RelativePathExpr - typically
        case reduced_node.name
        when RelativePathExpr
          puts "determ: relative"
          expr = RelativePathExprHandle.new(reduced_node)
        when VarRef
          puts "determ: var"
          expr = VarRefHandle.new(reduced_node)
        when ParenthesizedExpr
          puts "determ: parenthesized"
          expr = Array.new
          singles = reduced_node.children[1].xpath("./ExprSingle")
          singles.each { |expr_single|
            expr << determine_expression(expr_single)
          }
         when CompAttrConstructor
           puts "determ: attr"
           expr = CompAttrConstructorHandle.new(reduced_node)
         when DirElemConstructor
           puts "determ: elem"
           expr = ElemConstructorHandle.new(reduced_node)
         when StringLiteral
           expr = DummyExpressionHandle.new("StringLiteral", reduced_node.content[1..-2])
         
        else
          raise NotSupportedError, reduced_node.name
        end
        return expr
      end
      
      
    end
  end
end