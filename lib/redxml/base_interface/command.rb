module BaseInterface
  # Represents a command sent into DBInterface in pipelined or transaction mode to be able to
  # replay them later.
  class Command
    attr_reader :method_name, :params
    
    def initialize(method_name, params)
      @method_name = method_name
      @params = params
    end
  end
end