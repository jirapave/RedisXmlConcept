require_relative "expression_module"
require_relative "expression_handle"
require "rubygems"
require "nokogiri"

module XQuery
  module ExpressionModule
    class DirElemConstructorHandle < ExpressionHandle
      
      def initialize(node)
        super(node)
        
        #TODO delete
        puts "   content: #{node.text}"
        #TODO delete
        
        
        @elem_str = nil
        
        
      end
      
      
      #find enclosed path expressions and vars
      #resolve them
      #build string with tags and these resolved results 
      def get_elem_str(path_solver, context=XQuerySolverContext.new, flwor_solver=nil)
        
        #hash with results
        enclosed_expr_hash = Hash.new
        
        #find eclosed expressions
        enclosed_nodes = node.xpath(".//EnclosedExpr/Expr") #predicate [not(descendant::EnclosedExpr)] do not work
        
        done_enclosed_nodes = []
        
        enclosed_nodes.each { |enclosed_node|
          
          #reduce them
          reduced = ExpressionModule::reduce(enclosed_node)
          reduced_text = reduced.text
          
          #reduce enclosed nodes so they do not embed each other
          incl = false
          done_enclosed_nodes.each { |done_str|
            puts "done: #{done_str} vs actual: #{reduced_text}"
            if(done_str.include?("{#{reduced_text}}"))
              incl = true
              break
            end
          }
          if(incl)
            next
          end
          
          #if already resolved -> skip
          if(enclosed_expr_hash[reduced_text])
            next
          end
          results = []
          case reduced.name
          when VarRef #enclosed expr VarRef type
            results = context.variables[reduced.children[1].text]
            
          when RelativePathExpr #enclosed expr RelativePathExpr type
            results = path_solver.solve(RelativePathExprHandle.new(reduced), context)
            
          when FLWORExpr
            results = flwor_solver.solve(FLWORExprHandle.new(reduced))
            enclosed_expr_hash[reduced_text] = results.join
            results = nil
            
          else
            raise NotSupportedError, reduced.name
          end
          
          
          if(results)
            result_str = ""
            results.each { |result|
              result_str << path_solver.path_processor.get_node(result).to_s
            }
            enclosed_expr_hash[reduced_text] = result_str
          end
          
          
          done_enclosed_nodes << reduced_text
        }
        final_elem_str = node.text#.gsub("{#{reduced_text}}", "#{reduced_text}")
        enclosed_expr_hash.keys.sort.reverse.each { |key|
          final_elem_str.gsub!("{#{key}}", enclosed_expr_hash[key])
        }
        
        
        return final_elem_str
      end
      
      
      def nokogiri_node(path_solver, context)
        if(!@elem_str)
          @elem_str = get_elem_str(path_solver, context)
        end
        
        xml_doc = Nokogiri.XML(@elem_str) do |config|
          config.default_xml.noblanks
        end
        return xml_doc.root
      end
      
      
    end
  end
end