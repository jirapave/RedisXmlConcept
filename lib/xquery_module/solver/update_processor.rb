module XQuery
  class UpdateProcessor < KeyPathProcessor
    
    attr_reader :key_builder
    
    
    #rather use static delete_nodes
    def delete_node(key_element_builder)
      if(key_element_builder.kind_of?(String))
        
      end
      if(key_element_builder.kind_of?(String) && !KeyElementBuilder.element?)
        delete_keys << key_element_builder.to_s
      else
        children = get_children_plain(key_element_builder)
        children.each { |child|
          
        }
        delete_keys << delete_node()
      end
    end
    
    
    
    def self.delete_nodes(key_element_builders)
      @db = BaseInterface::DBInterface.instance
      @db.pipelined do
        
        processor_pool = Hash.new
        key_element_builders.each { |builder|
          key_builder = builder.key_builder
          processor = processor_pool[key_builder.to_s]
          if(processor == nil)
            processor = UpdateProcessor.new(key_builder)
          end
          processor.delete_node(builder)
        }
        
      end
    end
    
  end
end