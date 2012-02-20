require_relative "../transformer/environment_service"
require_relative "environment"

module RedXmlApi
  class EnvironmentManager
    def initialize()
      @env_service = Transformer::EnvironmentService.new
    end
    
    def create_environment(name)
      begin
        @env_service.create_environment(name)
        return Environment.new(name)
      rescue Transformer::MappingException => ex
        puts ex.message
        puts "No environment was created."
      end
    end
    
    def delete_environment(name)
      
    end
    
    def get_environment(name)
      
    end
    
    def get_all_environments()
      
    end
    
    def rename_environment(old_name, name)
      
    end
    
  end
end