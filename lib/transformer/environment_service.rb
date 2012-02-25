require_relative "../base_interface/db_interface"
require_relative "key_builder"
require_relative "exceptions"

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
      raise Transformer::MappingException, "Environment with such a name already exist." unless result
      env_id
    end
    
    def delete_environment(name)
      
    end
    
    def delete_all_environments()
      
    end
    
    def get_environment_id(name)
      env_key = Transformer::KeyBuilder.environments_key()
      env_id = @db_interface.get_hash_value(env_key, name)
      raise Transformer::MappingException, "Environment with such a name doesn't exist." unless env_id
      env_id
    end
    
    def get_all_environment_ids()
      env_key = Transformer::KeyBuilder.environments_key()
      return @db_interface.get_all_hash_values(env_key)
    end
    
    def rename_environment(old_name, name)
      env_key = Transformer::KeyBuilder.environments_key()
      #Verify that new name isn't already in database
      result = @db_interface.hash_value_exist?(env_key, name)
      raise Transformer::MappingException, "Environment with such a name already exist." if result
      
      #Delete old enevironment
      old_id = get_environment_id(old_name)
      deleted_iter = @db_interface.delete_from_hash(env_key, old_name)
      raise Transformer::MappingException, "Cannot delete old environment's name, rename aborted." if deleted_iter != 1
      
      #Create new maping
      result = @db_interface.add_to_hash_ne(env_key, name, old_id)
      unless result
        #trying to avoid lost of whole environment, restore old mapping
        result = @db_interface.add_to_hash_ne(env_key, old_name, old_id)
        raise Transformer::FatalError, "Fatal error, renaming failed, old environment is lost" unless result
        raise Transformer::MappingException, "Renaming failed." if result
      end
    end
  end
end