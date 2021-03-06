require_relative "../transformer/environment_service"
require_relative "environment"

module RedXmlApi
  class EnvironmentManager
    def initialize()
      @env_service = Transformer::EnvironmentService.new
    end
    
    def create_environment(name)
      begin
        env_id = @env_service.create_environment(name)
        return Environment.new(env_id)
      rescue Transformer::MappingException => ex
        puts ex.message
        puts "No environment was created."
      end
    end
    
    def delete_environment(name)
      begin
        @env_service.delete_environment(name)
      rescue Exception => ex
        ex.message
        puts "Unknown error has occured."
      end
    end
    
    def delete_all_environments
      begin
        @env_service.delete_all_environments
      rescue Exception => ex
        ex.message
        puts "Unknown error has occured."
      end
    end
    
    def get_environment(name)
      begin
        env_id = @env_service.get_environment_id(name)
        return Environment.new(env_id)
      rescue Transformer::MappingException => ex
        puts ex.message
        puts "Environment can't be obtained."
      end
    end
    
    def get_all_environments()
      begin
        all_ids = @env_service.get_all_environment_ids
        result = []
        all_ids.each do |id|
          result << Environment.new(id)
        end
        return result
      rescue Exception => ex
        puts "Unknown error occured, please try again." 
        puts ex.message
      end
    end
    
    def get_all_environments_names()
      @env_service.get_all_environment_names
    end
    
    def rename_environment?(old_name, name)
      begin
        @env_service.rename_environment(old_name, name)
        return true
      rescue Transformer::MappingException => ex
        puts ex.message
        puts "Environment could't be renamed."
        return false
      end
    end
    
  end
end