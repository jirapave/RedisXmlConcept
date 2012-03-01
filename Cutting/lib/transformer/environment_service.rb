require_relative "../base_interface/db_interface"
require_relative "../red_xml_api/environment"
require_relative "key_builder"
require_relative "exceptions"

module Transformer
  class EnvironmentService
    def initialize
      @db_interface = BaseInterface::DBInterface.instance
      @env_key = Transformer::KeyBuilder.environments_key()
    end
    
    def create_environment(name)
      env_id = @db_interface.increment_hash(@env_key, Transformer::KeyElementBuilder::ITERATOR_KEY, 1)
      result = @db_interface.add_to_hash_ne(@env_key, name, env_id)
      raise Transformer::MappingException, "Environment with such a name already exist." unless result
      env_id
    end
    
    def delete_environment(name)
      #Delete environment = delete all collections in it and than delete field in environments key
      env_id = get_environment_id(name)
      RedXmlApi::Environment.new(env_id).delete_all_collections
      @db_interface.delete_from_hash @env_key, name
    end
    
    def delete_all_environments()
      all_names = get_all_environment_names()
      all_names.each do |name|
        delete_environment(name)
      end
    end
    
    def get_environment_id(name)
      env_id = @db_interface.get_hash_value(@env_key, name)
      raise Transformer::MappingException, "Environment with such a name doesn't exist." unless env_id
      env_id
    end
    
    def get_all_environment_ids()
      #Remember there is a field <iterator> which we have to exclude
      iter_id = @db_interface.get_hash_value(@env_key, Transformer::KeyBuilder::ITERATOR_KEY)
      #We have to exclude first occurence of iter_id
      result = @db_interface.get_all_hash_values(@env_key)
      if iter_id
        ind = nil
        result.each_with_index do |id, index|
          if id == iter_id
            ind = index
            break
          end
        end
        result.delete_at(ind) if ind
      end
      return result
    end
    
    def get_all_environment_names()
      names =  @db_interface.get_all_hash_fields(@env_key)
      ind = nil
      names.each_with_index do |name, index|
        if name == Transformer::KeyBuilder::ITERATOR_KEY
          ind = index
          break
        end
      end
      names.delete_at(ind) if ind
      return names
    end
    
    def rename_environment(old_name, name)
      #Verify that new name isn't already in database
      result = @db_interface.hash_value_exist?(@env_key, name)
      raise Transformer::MappingException, "Environment with such a name already exist." if result
      result = @db_interface.hash_value_exist?(@env_key, old_name)
      raise Transformer::MappingException, "Cannot rename, environment #{old_name} doesn't exist." unless result
      
      #Delete old enevironment
      old_id = get_environment_id(old_name)
      result = @db_interface.transaction do
        @db_interface.delete_from_hash(@env_key, old_name)
        @db_interface.add_to_hash_ne(@env_key, name, old_id)
      end
      
      #Note: result may obtain some old return values from redis, we have to lookup at the end of result
      raise Transformer::MappingException, "Cannot delete old environment's name, rename aborted." if result[-2] != 1
      raise Transformer::MappingException, "Renaming failed." if result[-1] != 1
      true
    end
    
    def environment_exist?(name)
      return @db_interface.hash_value_exist?(@env_key, name)
    end
  end
end