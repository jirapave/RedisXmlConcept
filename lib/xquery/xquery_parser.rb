require_relative "expression"
require_relative "sequence"
require_relative "query_string_error"

#TODO handle better the keyword ORDER BY


module XQuery
  class XQueryParser
    
    def self.parse_query(query)
      
      #declare variables
      root_expression = Expression.create(nil, Expression::GROUP)
      expression = root_expression
      atomic_expr = ""
      
      #flags
      whitespace_before = false
      return_clause = false #after return keyword there are different rules,
                            # e.g. <elem>$proc/name</elem> (<elem... will be displayed in results)
      tag_brackets = 0 #we use that during return clause parsing
      str_apostrophe = false #enclosed with ', so whitespaces and all are stored too
      str_quotation = false #enclosed with ", so whitespaces and all are stored too
      
      #bracket stack for validating and right dividing expressions and subexpressions
      bracket_stack = []
      
      
      #recapitulation block - DEBUG purposes
      recapitulation = Proc.new {
        puts ""
        puts "----==== REKAPITULACE ====----"
        root_expression.walkthrough
        puts "actual expression #{expression.type}"
        puts "----==== KONEC ====----"
        puts ""
      }
      
      #add new STRING expression
      add_string_expression = Proc.new {
        
        #DEBUG TODO delete
        # puts "adding expression: #{atomic_expr}, type: Atomic String"
        
        new_expr = Expression.create(expression, Expression::ATOMIC_VALUE)
        new_expr.parts << AtomicValue.new(atomic_expr, AtomicValue::STRING)
        atomic_expr = ""
      }
      
      #add new unspecified expression
      add_expression = Proc.new {
        if(!atomic_expr.empty?)
          if(expression.kind_of?(NamedExpression))
            
            #DEBUG TODO delete
            # puts "adding expression: #{atomic_expr}, type: #{expression.type}"
            
            expression.name = atomic_expr
            expression = expression.parent
            
          else
            new_expr = Expression.create(expression, Expression::BASIC, atomic_expr)
            
            #DEBUG TODO delete
            # puts "adding expression: #{atomic_expr}, type: #{new_expr.type}"  
            
            #is that RETURN? we need to determine that to change this flag
            if(new_expr.type == Expression::RETURN)
              return_clause = true
            end
          end
          
          # rekapitulace DEBUG TODO delete
          # recapitulation.call
          
          atomic_expr = ""
        end
      }
      
      whitespace_function = Proc.new {
        if(!whitespace_before)
          add_expression.call
          if(expression.type == Expression::STEP)
            expression = expression.parent.parent
          elsif(expression.type == Expression::XPATH)
            expression = expression.parent 
          end
        end
      }
      
      
      for i in 0..(query.length-1)
        ch = query[i]
      
        
      
        #check ' or "
        if(ch.match(/['"]/))
          if(ch == '\'' && !str_quotation)
            str_apostrophe = !str_apostrophe
            if(!str_apostrophe)
              add_string_expression.call
            elsif(expression.type == Expression::BINARY_OPERATOR)
              add_expression.call
            end
          elsif(ch == '"' && !str_apostrophe)
            str_quotation = !str_quotation
            if(!str_quotation)
              add_string_expression.call
            elsif(expression.type == Expression::BINARY_OPERATOR)
              add_expression.call
            end
          end
          
          whitespace_before = false
          next
        end
        
        #if string in progress
        if(str_apostrophe || str_quotation)
          atomic_expr << ch
          next
        end
      
      
      
      
        if(ch.match(/\S/)) # if not a whitespace character
      
          # bracket logic
          if(ch.match(/[\(\[\{]/)) # if opening bracket comming
            bracket_stack << ch
            
            # (
            if(ch == '(')
              if(atomic_expr.empty?) #GROUP (probably sequence in the end)
                new_expr = Expression.create(expression, Expression::GROUP)
                expression = new_expr
              else #FUNCTION
                
                #DEBUG TODO delete
                # puts "new function #{atomic_expr} created"
                
                new_expr = Function.new(expression, atomic_expr)
                atomic_expr = ""
                expression = new_expr
              end
            elsif(ch == '[') #PREDICATE
              if(atomic_expr.empty?)
                raise QueryStringError, "there is nothing before predicate, char number #{i} = #{ch}, query: #{query}"
              end
              expression.name = atomic_expr
              atomic_expr = ""
              new_expr = Expression.create(expression, Expression::PREDICATE)
              expression = new_expr
            elsif(ch == '{') # not sure yet
              if(!atomic_expr.empty?)
                add_string_expression.call
              end
              new_expr = Expression.create(expression, Expression::GROUP)
              expression = new_expr
            end
            
          elsif(ch.match(/[\)\]\}]/)) # if closing bracket comming
            if(bracket_stack.pop != opposite_bracket(ch))
              raise QueryStringError, "wrong order of brackets in char number #{i} = #{ch}, query: #{query}"
            end
            
            #end of any expression
            add_expression.call
            expression = expression.parent
            
            #DEBUG TODO delete
            # puts "bracket #{ch} stepped process up"
            
            # recapitulation.call
            
          elsif(ch == '/')#slash -> xpath element
            
            #RETURN clause
            if(return_clause && tag_brackets > 0)
              atomic_expr << ch
              
            else
              if(atomic_expr.empty?) #some end of bracket was before or variable or another slash
                if(expression.type == Expression::STEP) #slash before
                  # empty ELEMENT expression will be stored, we'll know that it is '//'
                  
                  #DEBUG TODO delete
                  # puts "step up to #{expression.parent.type} and creating STEP"
                  
                  expression = expression.parent
                else
                  # we need to create XPATH expression and add it to previouses expression parent 
                  # while this previous expression is the first step of XPATH expression
                  # ! from what I know there is no way the slash would be the first character in XPATH expression 
                  prev_expr = expression.parts.pop
                  
                  #DEBUG TODO delete
                  # puts "xpath step previous #{prev_expr}"
                  
                  xpath_expr = Expression.create(expression, Expression::XPATH)
                  if(prev_expr.respond_to?(:name))
                    prev_step = XPathStep.new(xpath_expr, prev_expr.type, prev_expr.name)
                  else
                    prev_step = XPathStep.new(xpath_expr, prev_expr.type)
                  end
                  prev_step.parts = prev_expr.parts
                  
                  expression = xpath_expr
                end
              else # simple ELEMENT was before (still opened)
                add_expression.call
                if(expression.type != Expression::XPATH)
                  prev_expr = expression.parts.pop
                  
                  xpath_expr = Expression.create(expression, Expression::XPATH)
                  prev_step = XPathStep.new(xpath_expr, prev_expr.type)
                  if(prev_expr.type == Expression::VARIABLE || prev_expr.type == Expression::ATTRIBUTE)
                    prev_step.name = prev_expr.name
                  else
                    prev_step.parts << prev_expr.parts
                  end
                  
                  expression = xpath_expr
                end
              end
            
              new_expr = XPathStep.new(expression)
              expression = new_expr
            end

            
          elsif(ch == '@')# attribute
            if(expression.type == Expression::STEP)
              expression.subtype = Expression::ATTRIBUTE
            else
              new_expr = Attribute.new(expression)
              expression = new_expr
            end
            
          elsif(ch == '$')# variable
            if(!atomic_expr.empty? && return_clause)
              add_expression.call
            end
            if(expression.type == Expression::BINARY_OPERATOR)
              add_expression.call
            end
            
            if(expression.type == Expression::STEP)
              expression.subtype = Expression::VARIABLE
            else
              new_expr = Variable.new(expression)
              expression = new_expr
            end
            
            
          elsif(ch.match(/[!=<>]/)) # if there is an global comparison expression
                                    # (we have to divide even when no white space between parameters provided)
            
            # RETURN clause handling                        
            if(return_clause && expression.type != Expression::PREDICATE)
              if(ch == '<')
                if(!atomic_expr.empty? && (expression.type == Expression::STEP || expression.type == Expression::XPATH))
                  whitespace_function.call
                end
                tag_brackets += 1
              elsif(ch == '>')
                tag_brackets -= 1
              end
              
            else                                    
              if(atomic_expr.empty?)
                new_expr = BinOperator.new(expression)
                expression = new_expr
              elsif(expression.type != Expression::BINARY_OPERATOR)
                add_expression.call
                if(expression.type == Expression::XPATH)
                  expression = expression.parent
                end
                new_expr = BinOperator.new(expression)
                expression = new_expr
              end
            end
            
            atomic_expr << ch
            
          else
            if(expression.type == Expression::BINARY_OPERATOR)
              add_expression.call
            end
            atomic_expr << ch
          end
          
        whitespace_before = false
          
        #whitespace
        else
          whitespace_function.call
          whitespace_before = true
        end
      end
      
      if(!whitespace_before)
        add_expression.call
      end
      
      #DEBUG TODO delete
      # puts "ENDING:"
      # recapitulation.call
      
      return root_expression
    end
    
    def self.opposite_bracket(ch)
      case ch
      when ')'
        '('
      when ']'
        '['
      when '}'
        '{'
      when '('
        ')'
      when '['
        ']'
      when '{'
        '}'
      end
    end
    
  end
end