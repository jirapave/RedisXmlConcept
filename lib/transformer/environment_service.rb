require_relative "../base_interface/db_interface"
require_relative "../red_xml_api/environment"
require_relative "key_builder"
require_relative "exceptions"

module Transformer
  # Class represents an abstraction layer which provides basic functionality to work with Environments. 
  # It is possible to create, delete or rename environments and much more.
  class EnvironmentService
    # Creates new instance of the EnvironmentService
    def initialize
      @db_interface = BaseInterface::DBInterface.instance
      @env_key = Transformer::KeyBuilder.environments_key()
      @env_iterator = Transformer::KeyBuilder.env_iterator_key
    end
    
    # Creates new environment with a given name in a database and returns it's ID
    # ==== Parameters
    # * +name+ - Name of the environment to be created
    # ==== Return value
    # String with the ID of the created environment
    # ==== Raises
    # Transformer::MappingException - If environment with such a name already exist
    def create_environment(name)
      env_id = @db_interface.increment_hash(@env_iterator, Transformer::KeyElementBuilder::ITERATOR_KEY, 1)
      result = @db_interface.add_to_hash_ne(@env_key, name, env_id)
      raise Transformer::MappingException, "Environment with such a name already exist." unless result
      #Create info hash for environment where iterator for generating ids of collections and files will be saved
      env_id
    end
    
    # Deletes environment with a given name from the database, if environment with such a name
    # does not exist method will return.
    # ==== Parameters
    # * +name+ - Name of the environment to be deleted
    def delete_environment(name)
      #Delete environment = delete all collections in it and than delete field in environments key
      env_id = nil
      begin
        env_id = get_environment_id(name)
      rescue Transformer::MappingException => ex
        ex.message
        return
      end
      RedXmlApi::Environment.new(env_id).delete_all_child_collections
      @db_interface.delete_from_hash @env_key, name
      info = Transformer::KeyBuilder.environment_info(env_id)
      @db_interface.delete_keys [info]
    end
    
    # Deletes all environments in a database.
    def delete_all_environments()
      all_names = get_all_environment_names()
      all_names.each do |name|
        delete_environment(name)
      end
    end
    
    # Returns ID for the environment specified by name.
    # ==== Parameters
    # * +name+ - Name of the environment for which the ID should be retrieved
    # ==== Return value
    # String with the ID of the environment
    # ==== Raises
    # Transformer::MappingException - If environment with such a name does not exist
    def get_environment_id(name)
      env_id = @db_interface.get_hash_value(@env_key, name)
      raise Transformer::MappingException, "Environment with such a name doesn't exist." unless env_id
      env_id
    end
    
    # Returns IDs of all environments in the database
    # ==== Return value
    # Array with IDs of all environments
    def get_all_environment_ids()
      ids = @db_interface.get_all_hash_values(@env_key)
      ids ||= []
      return ids
    end
    
    # Returns names of all environments in the database
    # ==== Return value
    # Array with names of all environments
    def get_all_environment_names()
      names =  @db_interface.get_all_hash_fields(@env_key)
      names ||= []
      return names
    end
    
    # Rename environment = change it's name, not ID
    # ==== Parameters
    # * +old_name+ - Name of the environment which should be renamed
    # * +name+ - New name for the environment
    # ==== Raises
    # Transformer::MappingException - If environment with old_name does not exist or if there already
    # is environment with name parameter as it's name
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
    end
    
    # Verifies if environment with a given name exist
    # ==== Return value
    # True if the environment with given name exist, False otherwise
    def environment_exist?(name)
      return @db_interface.hash_value_exist?(@env_key, name)
    end
  end
end