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
  
  class Function < Expression
    
    POSITION = :position
    LAST = :last
    NOT = :not
    TEXT = :text
    DATA = :data
    
    def initialize(parent, name, parameters=[])
      super(parent, Expression::FUNCTION, parameters)
      @name = name
    end
    
    def print_self
      puts "Expression type:#{@type}, name:#{@name}, parameter_count: #{@parts.length}"
    end
    
    attr_reader :name
  end
  
  class Variable < Expression
    def initialize(parent, name="", value=nil) #name:String, value:Sequence
      super(parent, Expression::VARIABLE)
      @name = name
      @value = value
    end
    
    def print_self
      puts "Expression type:#{@type}, name:#{@name}, value: #{@value}"
    end
    
    attr_accessor :name, :value
  end
  
  class XPathStep < Expression
    def initialize(parent, subtype=ELEMENT, name="")
      super(parent, Expression::STEP)
      @name = name
      @subtype = subtype
    end
    
    def print_self
      puts "Expression type:#{@type}, subtype:#{@subtype}, maybe name: #{@name}"
    end
    
    attr_accessor :subtype, :name
  end
  
end