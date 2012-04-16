require_relative "FLWORExpr_handle"
require_relative "RelativePathExpr_handle"
require_relative "DeleteExpr_handle"
require_relative "InsertExpr_handle"
require_relative "expression_handle"
require_relative "../exceptions"

module XQuery
  module ExpressionModule
    
    #expression types
    FLWORExpr = "FLWORExpr"
    RelativePathExpr = "RelativePathExpr"
    FunctionCall = "FunctionCall"
    AbbrevForwardStep = "AbbrevForwardStep"
    ComparisonExpr = "ComparisonExpr"
    ForClause = "ForClause"
    LetClause = "LetClause"
    WhereClause = "WhereClause"
    OrderByClause = "OrderByClause"
    Predicate = "Predicate"
    ReturnExpr = "ReturnExpr"
    StepExpr = "StepExpr"
    DirElemConstructor = "DirElemConstructor"
    DirElemContent = "DirElemContent"
    ReturnText = "ReturnText"
    
    StringLiteral = "StringLiteral"
    NumericLiteral = "NumericLiteral"
    IntegerLiteral = "IntegerLiteral"
    DecimalLiteral = "DecimalLiteral"
    DoubleLiteral = "DoubleLiteral"
    Literal = :Literal
    
    PrimaryExpr = "PrimaryExpr"
    ForwardStep = "ForwardStep"
    PredicateList = "PredicateList"
    VarRef = "VarRef"
    ContextItemExpr = "ContextItemExpr"
    
    GeneralComp = "GeneralComp"
    ValueComp = "ValueComp"
    
    DeleteExpr = "DeleteExpr"
    InsertExpr = "InsertExpr" 
    ParenthesizedExpr = "ParenthesizedExpr"
    CompAttrConstructor = "CompAttrConstructor"
    #expression types
     
    
    def self.create_expr(node)
      reduced_node = reduce(node)
      case reduced_node.name
        
      when FLWORExpr
        return FLWORExprHandle.new(reduced_node)
        
      when RelativePathExpr
        return RelativePathExprHandle.new(reduced_node)
        
      when VarRef
        return VarRefHandle.new(reduced_node)
        
      when DeleteExpr
        return DeleteExprHandle.new(reduced_node)
        
      when InsertExpr
        return InsertExprHandle.new(reduced_node)
        
      else
        puts "WARNING: creating generic expression #{reduced_node.name}"
        return ExpressionHandle.new(reduced_node)
      end
    end
    
    def self.reduce(node, content=nil)
      if(content.nil?)
        content = node.content
      end
      node.children.each { |n|
        if(!n.content.empty? && n.content == content)
          return reduce(n, content)
        end
      }
      if(node.name == "text")
        return node.parent
      end
      return node
    end
    
    def self.checked_reduce(node, preffered_type, content=nil)
      if(content.nil?)
        content = node.content
      end
      if(node.name == preffered_type)
        return node
      end
      node.children.each { |n|
        if(!n.content.empty? && n.content == content)
          return checked_reduce(n, preffered_type, content)
        end
      }
      if(node.name == "text")
        return node.parent
      end
      return node
    end
    
  end
end