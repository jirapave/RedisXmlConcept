require_relative "expression_module"
require_relative "expression_handle"
require "rubygems"
require "nokogiri"

module XQuery
  module ExpressionModule
    class ElemConstructorHandle < ExpressionHandle
      
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
      def get_elem_str(path_solver, context)
        
        #hash with results
        enclosed_expr_hash = Hash.new
        
        #find eclosed expressions
        enclosed_nodes = node.xpath(".//EnclosedExpr/Expr")
        enclosed_nodes.each { |enclosed_node|
          #reduce them
          reduced = ExpressionModule::reduce(enclosed_node)
          reduced_text = reduced.text
          #if already resolved -> skip
          if(enclosed_expr_hash[reduced_text])
            next
          end
          results = []
          case reduced.name
          when VarRef #enclosed expr VarRef type
            results = context.variables[reduced.children[1].text]
            
          when RelativePathExpr #enclosed expr RelativePathExpr type
            enclosed_expr_hash[reduced_text] = path_solver.solve(RelativePathExpr.new(reduced), context)
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
        }
        
        final_elem_str = node.text
        enclosed_expr_hash.each { |key, value|
          final_elem_str.gsub!(key, value)
        }
        
        puts "elem_str: #{final_elem_str}"
        
        return final_elem_str
        
      end
      
      
      def nokogiri_node(path_solver, context)
        if(!@elem_str)
          @elem_str = get_elem_str(path_solver)
        end
        
        xml_doc = Nokogiri.XML(node.text) do |config|
          config.default_xml.noblanks
        end
        return xml_doc.root
      end
      
      
    end
  end
end