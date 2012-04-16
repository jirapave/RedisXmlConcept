require_relative "expression_module"
require_relative "expression_handle"
module XQuery
  module ExpressionModule
    class ElemConstructorHandle < ExpressionHandle
      
      attr_reader :name, :children, :attributes
      
      def initialize(node)
        super(node)
        
        #TODO delete
        puts "initializing ElemConstructor"
        #TODO delete
        
        # puts node.to_xml(:ident => 2)
        
        @key_element_builder = nil
        
        #init name
        @name = node.children[1].text
        puts "   name: #{@name}"
        
        #init attributes
        attribute_list = node.children[2]
        attr_names = attribute_list.xpath("./QName")
        attr_values = attribute_list.xpath("./DirAttributeValue")
        @attributes = Hash.new
        attr_names.each_with_index { |name, index|
          @attributes[name.text] = attr_values[index].text[1..-2]
        }
        puts "   attrs: #{@attributes.inspect}"
        
        #init children
        puts "    children:"
        @children = []
        text = ""
        add_text = Proc.new {
          if(!text.empty?)
            @children << TextNode.new(text)
            puts "   added text: #{text}"
            text = ""
          end
        }
        contents = node.xpath("./DirElemContent")
        contents.each { |content|
          child = ExpressionModule::reduce(content)
          #ElementContentChar
          if(child.name == "DirElemConstructor")
            add_text.call
            @children << ElemConstructorHandle.new(child)
          elsif(child.name == "ElementContentChar")
            text << child.text
          else
            raise StandardError, "this should be nothing else but DirElemConstructor or ElementContentChar, it is: #{child.name}"
          end
        }
        add_text.call
        
      end
      
      #recursively initializes key to store
      #children and attributes will be ready (id-wise) to store to databse, mapping will be performed (stored to db) here directly
      def set_key(key_element_builder, mapping_service)
        @key_element_builder = key_element_builder
        child_text_iterator = 0
        child_elem_iterator_hash = Hash.new
        @children.each { |child|
          if(child.kind_of?(TextNode))
            child.key_str = key_element_builder.text(child_text_iterator)
            child_text_iterator += 1
          else
            
            #get new elem_id
            begin
              elem_id = mapping_service.map_elem_name(child.name)
            rescue Transformer::MappingException
              elem_id = mapping_service.create_elem_mapping(child.name)
            end
            
            #get new elem_id order
            order = child_elem_iterator_hash[elem_id]
            if(!order)
              order = 0
            end
            
            child.set_key(key_element_builder.elem(elem_id, order))
            order += 1
          end
        }
        
        #set ids to the attribute hash
        id_attributes = Hash.new
        @attributes.each { |key, value|
          begin
            attr_id = mapping_service.map_attr_name(key)
          rescue Transformer::MappingException
            attr_id = mapping_service.create_attr_mapping(key)
          end
          
          id_attributes[attr_id] = value
        }
        @attributes = id_attributes
      end
      
      def attr_key
        @key_element_builder.attr
      end
      
    end
    
    class TextNode
      
      attr_reader :text
      attr_accessor :key_str
      
      def initialize(text)
        @text = text
        @key_str = nil
      end
      
    end
    
  end
end