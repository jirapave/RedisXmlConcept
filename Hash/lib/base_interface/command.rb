module BaseInterface
  class Command
    attr_reader :method_name, :params
    
    def initialize(method_name, params)
      @method_name = method_name
      @params = params
    end
  end
end