module XQuery
  class NodeStoreProcessor
    
    def initialize(mapping_service, content_hash_key)
      @content_hash_key = content_hash_key
      @mapping_service = mapping_service
      @db = BaseInterface::DBInterface.instance
    end
    
    
    def save_node(nokogiri_node, key_element_builder)
      
      #save attributes
      save_attributes(nokogiri_node, key_element_builder)
      
      #save children
      elem_id_hash = Hash.new
      text_order = 0
      comment_order = 0
      cdata_order = 0
      children_keys = []
      nokogiri_node.children.each { |child|
        child_key = nil
        if(child.element?)
          elem_id = get_elem_id(child.name)
          order = elem_id_hash[elem_id]
          order = 0 unless(order)
          child_key = Transformer::KeyElementBuilder.build_from_s(key_element_builder.key_builder, key_element_builder.elem(elem_id, order))
          # child_key = key_element_builder.elem(elem_id, order)
          elem_id_hash[elem_id] = (order+1)
          
          #save this child node recursively
          save_node(child, child_key)
          
        else
          if(child.text?)
            child_key = key_element_builder.text(text_order)
            text_order += 1
            
          elsif(child.comment?)
            child_key = key_element_builder.comment(comment_order)
            comment_order += 1
            
          elsif(child.cdata?)
            child_key = key_element_builder.comment(cdata_order)
            cdata_order += 1
            
          else
            raise StandardError, "not supported other sort of child: #{child.class}"
          end
          
          #save text/comment/cdata to db
          @db.add_to_hash(@content_hash_key, [ child_key, child.text ])
        end
        
        #add child to children keys
        children_keys << child_key.to_s
      }
      
      #save children_keys to this nodes content
      @db.add_to_hash(@content_hash_key, [ key_element_builder.to_s, children_keys.join(KeyPathProcessor::CHILDREN_SEPARATOR) ])
      
    end
    
    def save_attributes(nokogiri_node, key_element_builder)
      #map attribute names to IDs
      attributes = Hash.new
      nokogiri_node.attributes.each { |key, value|
        attributes[get_attr_id(key)] = value
      }
      #store attributes do database
      if(!attributes.empty?)
        @db.add_to_hash(@content_hash_key, \
            [ key_element_builder.attr, \
              attributes.to_a.flatten.join( \
                Transformer::XMLTransformer::ATTR_SEPARATOR \
              ) ])
      end
    end
    
    def get_attr_id(attr_name)
      begin
        return @mapping_service.map_attr_name(attr_name)
      rescue Transformer::MappingException
        return @mapping_service.create_attr_mapping(attr_name)
      end
    end
    
    def get_elem_id(elem_name)
      begin
        return @mapping_service.map_elem_name(elem_name)
      rescue Transformer::MappingException
        return @mapping_service.create_elem_mapping(elem_name)
      end
    end
    
  end
end