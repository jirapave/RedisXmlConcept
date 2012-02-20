require_relative "../base_interface/db_interface"
require_relative "key_builder"

module Transformer
  class EnvironmentService
    def initialize
      #TODO Idea, what about module, which will create insttance variable db_interface so
      #each class which works with db would just include module
      @db_interface = BaseInterface::DBInterface.instance
    end
    
    def create_environment(name)
      #TODO exception handling if name exist, maybe raise own exception?
      env_key = Transformer::KeyBuilder.environments_key()
      env_id = @db_interface.increment_hash(env_key, Transformer::KeyElementBuilder::ITERATOR_KEY, 1)
      result = @db_interface.add_to_hash_ne(env_key, name, env_id)
      raise MappingException, "Environment with such a name already exist." unless result
      result
    end
    
    def delete_environment(name)
      
    end
    
    def get_environment(name)
      
    end
    
    def get_all_environments()
      
    end
    
    def rename_environment(old_name, name)
      
    end
    
    class MappingException < StandardError
      def message
        "Error has occured during mapping name to id"
      end
    end
  end
end