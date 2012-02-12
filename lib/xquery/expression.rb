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
    
    #other keywords
    IN = :in
    AT = :at
    
    KEYWORDS = [FOR, LET, WHERE, ORDER_BY, RETURN,
                IN, AT]
    
    def initialize(parent=nil, type=BASIC, parts=[])
      @type = type
      @parent = parent #:Expression
      @parts = parts #also Expressions or strings...
      
      # add self to the parent's parts
      if(@parent != nil)
        @parent.parts << self
      end
      
      # determine keyword
      if(type == BASIC && parts.kind_of?(String))
        case parts
        when "for"
          @parts = []; @type = FOR
        when "let"
          @parts = []; @type = LET
        when "where"
          @parts = []; @type = WHERE
        when "order"
          @parts = []; @type = ORDER_BY
        when "return"
          @parts = []; @type = RETURN
        when "in"
          @parts = []; @type = IN
        when "at"
          @parts = []; @type = AT
        end
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
            if(part.instance_of?(AtomicValue))
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
  
  class Function < Expression
    def initialize(parent, name, parameters=[])
      @type = FUNCTION
      @parent = parent
      
      # add self to the parent's parts
      if(@parent != nil)
        @parent.parts << self
      end
      
      @name = name
      @parts = parameters
    end
    
    def print_self
      puts "Expression type:#{@type}, name:#{@name}, parameter_count: #{@parts.length}"
    end
    
    attr_reader :name
    attr_accessor :parameters
  end
  
  class Variable < Expression
    def initialize(parent, name="", value=nil) #name:String, value:Sequence
      @type = VARIABLE
      @parent = parent
      
      # add self to the parent's parts
      if(@parent != nil)
        @parent.parts << self
      end
      
      @name = name
      @value = value
    end
    
    def print_self
      puts "Expression type:#{@type}, name:#{@name}, value: #{@value}"
    end
    
    attr_accessor :name, :value
  end
  
  class XPathStep < Expression
    def initialize(parent, subtype=ELEMENT)
      @type = STEP
      @parent = parent
      @parts = []
      
      # add self to the parent's parts
      if(@parent != nil)
        @parent.parts << self
      end
      
      @subtype = subtype
    end
    
    def print_self
      puts "Expression type:#{@type}, subtype:#{@subtype}"
    end
    
    attr_accessor :subtype
  end
  
end