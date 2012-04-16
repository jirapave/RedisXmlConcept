require_relative "../ext/delete_key_box"
require_relative "key_path_processor"

module XQuery
  class DeleteProcessor < KeyPathProcessor
    
    attr_reader :key_builder
    
    @@processor_pool = Hash.new
    
    # def initialize(key_builder)
      # super(key_builder)
      # puts "init with key_builder: #{key_builder}"
      # @content_hash_key = content_hash_key
      # puts "init content hash key: #{@content_hash_key}"
    # end
    
    #rather use static delete_nodes
    def delete_node(key_str)
      
      if(Transformer::KeyElementBuilder.element?(key_str))
        key_element_builder = Transformer::KeyElementBuilder.build_from_s(nil, key_str)
        children = get_plainly_children(key_str)
        children.each { |child|
          delete_node(child)
        }
        # @db.delete_entries([ key_element_builder.attr, key_str ])
        puts "2deleting key: #{key_element_builder.attr}"
        puts "3deleting key: #{key_str}"
        
        @db.delete_from_hash(@content_hash_key, [ key_element_builder.attr, key_str ])
      else
        puts "1deleting key: #{key_str}"
        # @db.delete_entries([ key_str ])
        
        @db.delete_from_hash(@content_hash_key, [ key_str ])
        
      end
    end
    
    
    def rewrite_parent(parent_key, parent_value)
      @db.add_to_hash(@content_hash_key, [ parent_key, parent_value ], true)
    end
    
    
    def self.delete_nodes(extended_keys, pipelined=true)
      if(pipelined)
        db = BaseInterface::DBInterface.instance
        db.pipelined do
          delete_nodes_only(extended_keys)
        end
      else
        delete_nodes_only(extended_keys)
      end
    end
    
  private
    def self.delete_nodes_only(extended_keys)
      delete_box = DeleteKeyBox.new
      
      extended_keys.each { |extended_key|
        key_builder = extended_key.key_builder
        pool_key = key_builder.to_s
        processor = @@processor_pool[pool_key]
        if(processor == nil)
          processor = DeleteProcessor.new(key_builder)
          @@processor_pool[pool_key] = processor
        end
        
        #remove reference of deleted key from his parent
        #so memorize what keys should be deleted and delete in the end all of them
        delete_key = extended_key.key_str
        delete_box.add_delete_key(delete_key, extended_key.parent_key, extended_key.parent_children_array, pool_key)
        
        #recursively delete node
        processor.delete_node(extended_key.key_str)
      }
      
      #store new parent contents
      delete_box.beans_to_store.each { |bean|
        processor = @@processor_pool[bean.key_builder_str]
        if(processor == nil)
          raise StandardError, "not possible"
        end
        processor.rewrite_parent(bean.parent_key, bean.parent_value)
      }
    end
    
  end
end