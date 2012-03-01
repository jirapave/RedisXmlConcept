# IMPORTANT: Do NOT add new expressions to parent's parts - it's taken care of in every expression constructor.

module XQuery
  class Expression
    
    #FLOWR
    FOR = :for
    LET = :let
    WHERE = :where
    ORDER_BY = :order_by
    RETURN = :return
    #FLOWR
    
    #XPath
    XPATH = :xpath #!parts are steps!
    ATTRIBUTE = :attribute
    PREDICATE = :predicate
    SPECIFIED_PREDICATE = :specified_predicate
    ELEMENT = :element #parts: namespace, name
    STEP = :step
    #XPath
    
    BASIC = :basic # for keywords like in, at, to etc. - will be probably replaced by specifics
    GROUP = :group
    SEQUENCE_EXPRESSION = :sequence # Sequence object as 1 part
    ATOMIC_VALUE = :atomic # AtomicValue object as 1 part
    BINARY_OPERATOR = :bin_operator
    
    #special class
    VARIABLE = :variable
    FUNCTION = :function #1. part as function name, next parts as parameters - other Expressions or strings
    
    
    
    def initialize(parent=nil, type=BASIC, parts=[])
      @type = type
      @parent = parent #:Expression
      @parts = parts #also Expressions or strings...
      
      # add self to the parent's parts
      if(@parent != nil)
        @parent.parts << self
      end
      
    end
    
    def self.create(parent=nil, type=BASIC, parts=[])
      if(type == BASIC && !parts.kind_of?(Array))
        case parts
        when "for"
          return For.new(parent)
        when "let"
          return Let.new(parent)
        when "where"
          return Where.new(parent)
        when "order by"
          return OrderBy.new(parent)
        when "by"
          begin
            prev = parent.parts.last
            if(prev.parts[0] == "order")
              parent.parts.delete(prev)
              return OrderBy.new(parent)
            end
          rescue Exception
            raise QueryStringError, "keyword BY is not following ORDER"
          end
        when "return"
          return Return.new(parent)
        else
          #check if that is binary operator - value comparison
          if(BinaryOperator.is_operator_name?(parts))
            return BinOperator.new(parent, parts)
          end
          
          return new(parent, type, [parts])
        end
        
      else
        return new(parent, type, parts)
        
      end
    end
    
    TAB_LENGTH = 4
    def print_self
      puts "Expression type:#{@type}"
    end
    
    def walkthrough(tab_count=0)
      (tab_count*TAB_LENGTH).times { printf(" ")  }
      print_self
      if(@parts.kind_of?(Array))
        @parts.each { |part|
          if(part.kind_of?(Expression))
            part.walkthrough(tab_count + 1)
          else
            ((tab_count+1)*TAB_LENGTH).times { printf(" ")  }
            if(part.kind_of?(AtomicValue))
              puts "Atomic value: #{part.value}, type: #{part.type}"
            else
              puts "Atomic value: #{part}"
            end
          end
        }
      else
        ((tab_count+1)*TAB_LENGTH).times { printf(" ")  }
        puts "Atomic value: #{@parts}"
      end
    end
    
    
    attr_accessor :type, :parts, :parent
    
  end
  
  
  class For < Expression
    
    attr_accessor :variable_name, :value
    
    def initialize(parent)
      super(parent, Expression::FOR, [])
      @variable_name = nil
      @value = []
    end
    
    def print_self
      puts "Expression type:#{@type}, var_name: #{@variable_name}, value: #{@value.inspect}"
    end
  end
  
  class Let < Expression
    
    attr_accessor :variable_name, :value
    
    def initialize(parent)
      super(parent, Expression::LET, [])
      @variable_name = nil
      @value = []
    end
    
    def print_self
      puts "Expression type:#{@type}, var_name: #{@variable_name}, value: #{@value.inspect}"
    end
  end
  
  class Where < Expression
    def initialize(parent)
      super(parent, Expression::WHERE, [])
    end
  end
  
  class OrderBy < Expression
    
    attr_accessor :value
    
    def initialize(parent)
      super(parent, Expression::ORDER_BY, [])
      @value = []
    end
    
    def print_self
      puts "Expression type:#{@type}, value: #{@value.inspect}"
    end
  end
  
  class Return < Expression #children will be ordinary parts - atomic strings and xpaths/variables
    def initialize(parent)
      super(parent, Expression::RETURN, [])
    end
  end
  
  
  class NamedExpression < Expression
    
    attr_accessor :name
    
    def initialize(parent, type, name="", parts=[])
      super(parent, type, parts)
      @name = name
    end
    
    def print_self
      puts "Expression type:#{@type}, name:#{@name}"
    end
    
  end
  
  class BinOperator < NamedExpression
    
    def initialize(parent, name="")
      super(parent, Expression::BINARY_OPERATOR, name)
    end
  end
  

  class Function < NamedExpression
    
    POSITION = :position
    LAST = :last
    NOT = :not
    TEXT = :text
    DATA = :data
    
    def initialize(parent, name, parameters=[])
      super(parent, Expression::FUNCTION, name, parameters)
    end
    
    def print_self
      puts "Expression type:#{@type}, name:#{@name}, parameter_count: #{@parts.length}"
    end
  end
  
  class Variable < NamedExpression
    
    def initialize(parent, name="")
      super(parent, Expression::VARIABLE, name)
    end
  end
  
  class Attribute < NamedExpression
    
    def initialize(parent, name="")
      super(parent, Expression::ATTRIBUTE, name)
    end
  end
  
  class Element
    
    def self.namespace(elem_name)
      splitted = elem_name.split(':')
      if(splitted.length == 1)
        return ""
      elsif(splitted.length == 2)
        return splitted[0]
      else
        raise QueryStringError, "name of the element is not valid: #{elem_name}"
      end
    end
    
    def name_only(elem_name)
      splitted = elem_name.split(':')
      if(splitted.length == 1)
        return splitted[0]
      elsif(splitted.length == 2)
        return splitted[1]
      else
        raise QueryStringError, "name of the element is not valid: #{elem_name}"
      end
    end
    
  end
  
  class XPathStep < NamedExpression
    
    attr_accessor :subtype
    
    def initialize(parent, subtype=ELEMENT, name="")
      super(parent, Expression::STEP, name)
      @subtype = subtype #can be ELEMENT, ATTRIBUTE and VARIABLE
    end
    
    def namespace
      if(@subtype == Expression::ELEMENT)
        return Element.namespace(@name)
      else
        raise StandardError, "cannot return namespace of Attribute or Variable"
      end
    end
    
    def name_only
      if(@subtype == Expression::ELEMENT)
        return Element.name_only(@name)
      else
        return @name
      end
    end
    
    def print_self
      puts "Expression type:#{@type}, subtype:#{@subtype}, maybe name: #{@name}"
    end
  end
  
  
end