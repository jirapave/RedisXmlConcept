require_relative "../expression/InsertExpr_handle"

module XQuery
  class InsertProcessor
    
    def initialize(path_solver)
      @path_solver = path_solver
      @key_path_processor_pool = Hash.new
    end
    
    
    #items as array of ExpressionHandles and location as ExtendedKey
    def insert_nodes(items, location, target=InsertExprHandle::TARGET_INTO_LAST, pipelined=true, context=XQuerySolverContext.new)
      
      @location_path_processor = @path_solver.path_processor
      
      if(pipelined)
        db = BaseInterface::DBInterface.instance
        db.pipelined {
          insert_nodes_only(items, location, target, context)
        }
      else
        insert_nodes_only(items, location, target, context)
      end
      
    end
    
    
  private
                        #expr handle, extended key
    def insert_nodes_only(items, location, target, context)
      items.each { |item|
        case item.type
          
        when ExpressionHandle::RelativePathExpr
          extended_keys_to_insert = @path_solver.solve(item, context)
          add_elements(extended_keys_to_insert, location, target)
          
        when ExpressionHandle::VarRef
          extended_keys_to_insert = context.variables[item.var_name]
          add_elements(extended_keys_to_insert, location, target)
          
        #adding constructor
        when ExpressionHandle::CompAttrConstructor
          case target
          when InsertExprHandle::TARGET_INTO, InsertExprHandle::TARGET_INTO_AS_LAST, InsertExprHandle::TARGET_INTO_AS_FIRST 
            add_attribute(item, location.key_element_builder)
          else
            add_attribute(item, Transformer::KeyElementBuilder.build_from_s(location.parent_key))
          end
          
          
        when ExpressionHandle::DirElemConstructor
          #TODO
          
          
        when ExpressionHandle::StringLiteral
          #TODO
          
        end
      }
    end
    
    
    def add_elements(extended_keys, location_extended_key, target)
      extended_keys.each { |extended_key|
        #item key path processor, mapping service
        pool_key = extended_key.key_builder
        item_key_path_processor = @key_path_processor_pool[pool_key.to_s]
        if(!key_path_processor)
          item_key_path_processor = KeyPathProcessor.new(pool_key)
          @key_path_processor_pool[pool_key.to_s] = item_key_path_processor
        end
        
        #retrieve the whole xml node (Nokogiri)
        root_node = key_path_processor.get_node(extended_key.key_element_builder)
        
        
        add_node(root_node, item_key_path_processor, extended_key.key_element_builder, target)
        
        
        
        
      }
      
    end
    
    def add_node(root_node, item_key_path_processor, location_extended_key, target)
      
      #location elem name and id
      elem_id = location_extended_key.key_element_builder.elem_id
      elem_name = mapping_service.unmap_elem_id(elem_id)
      
      #init
      mapping_service = @location_path_processor.mapping_service
      
      #save the new node to db according target
      case target
      when InsertExprHandle::TARGET_BEFORE, InsertExprHandle::TARGET_AFTER
        parent_key = location_extended_key.parent_key
        parent_children_array = location_extended_key.parent_children_array
        location_key = location_extended_key.key_element_builder
        location_key_index = nil #will be found in parent_children_array
        max_order = -1
        parent_children_array.each_with_index { |key_str, index|
          elem_builder = Transformer::KeyElementBuilder.build_from_s(key_str)
          
          #set order of new node
          if(elem_builder.elem_name == elem_name)
            actual_order = elem_builder.order
            if(actual_order > max_order)
              max_order = actual_order
            end
          end
          
          #find sibling
          if(key_str == location_key.to_s)
            location_key_index = index
          end
        }
        
        case target
        when InsertExprHandle::TARGET_BEFORE
          item_elem_name = root_node.name
          item_elem_id = nil
          begin
            item_elem_id = mapping_service.map_elem_name(item_elem_name)
          rescue Transformer::MappingException
            item_elem_id = mapping_service.create_elem_mapping(item_elem_name)
          end
          new_key = location_key.parent.elem(item_elem_id, max_order+1)
        end
        
        
      else
        
        
      end
      
      
    end
    
    def add_attribute(attr_expr, key_element_builder)
      #prepare new attr name and value
      attr_name = attr_expr.attr_name
      attr_value = attr_expr.attr_value
      
      #get content hash key, db_interface, xml_transformer
      content_hash_key = @location_path_processor.content_hash_key
      db = BaseInterface::DBInterface.instance
      xml_transformer = @location_path_processor.xml_transformer
      
      #get mapping service
      mapping_service = @location_path_processor.mapping_service
      
      #retrieve new attr_name's ID
      attr_id = nil
      begin
        attr_id = mapping_service.map_attr_name(attr_name)
      rescue Transformer::MappingException
        attr_id = mapping_service.create_attr_mapping(attr_name)
      end
      
      #get attribute hash
      attr_hash = xml_transformer.get_attributes(key_element_builder, false)
      
      #save new attribute to that hash
      attr_hash[attr_id] = attr_value
      
      #save that back to database
      attrs_plain = ""
      attr_hash.each { |key, value|
        if(!attrs_plain.empty?)
          attrs_plain << Transformer::XMLTransformer::ATTR_SEPARATOR
        end
        attrs_plain << key << Transformer::XMLTransformer::ATTR_SEPARATOR << value
      }
      db.add_to_hash(content_hash_key, [key_element_builder.attr, attrs_plain], true)
      
    end
    
    
  end
end