require_relative "key_path_processor"

module XQuery
  class UpdateProcessor < KeyPathProcessor
    
    attr_reader :key_builder
    
    
    #rather use static delete_nodes
    def delete_node(key_str)
      
      
      #TODO delete from content, not from database!!
      
      if(Transformer::KeyElementBuilder.element?(key_str))
        key_element_builder = Transformer::KeyElementBuilder.build_from_s(nil, key_str)
        children = get_children_plain(key_element_builder)
        children.each { |child|
          delete_node(child)
        }
        @db.delete_entries([ key_element_builder.attr, key_str ])
        puts "2deleting key: #{key_element_builder.attr}"
        puts "3deleting key: #{key_str}"
      else
        puts "1deleting key: #{key_str}"
        @db.delete_entries([ key_str ])
      end
    end
    
    
    def self.delete_nodes(key_element_builders)
     
      puts "pipelined deleting: #{key_element_builders.inspect}"
      
      @db = BaseInterface::DBInterface.instance
      @db.pipelined do
        
        processor_pool = Hash.new
        key_element_builders.each { |builder|
          # key_builder = nil
          # if(builder.kind_of?(String))
            # key_builder = Transformer::KeyElementBuilder.build_from_s(builder).key_builder
          # else
            key_builder = builder.key_builder
          # end
          processor = processor_pool[key_builder.to_s]
          if(processor == nil)
            processor = UpdateProcessor.new(key_builder)
          end
          
          #delete also references from parents
          parent_value = @db.find_value(builder.parent.to_s)
          
          
          #recursively delete node
          processor.delete_node(builder.to_s)
        }
      end
    end
    
  end
end