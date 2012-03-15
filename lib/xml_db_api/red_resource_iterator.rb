require_relative "base/resource_set"
require_relative "base/xmldb_exception"
require_relative "base/error_codes"

module XMLDBApi
  class RedResourceIterator
    
      def initialize(resources)
        @resources = resources
        @pos = 0
      end
    
      # Returns true as long as there are still more resources to be iterated.
      # ==== Return value
      # True if there are more resources to iterate, false otherwise.
      def has_more_resources()
        if @resources.length > @pos
          return true
        else
          return false
        end
      end
      
      # Returns the next Resource instance in the iterator.
      # ==== Return value
      # Returns the next Resource instance in the iterator.
      # ==== Raises
      # XMLDBApi::Base::XMLDBException with expected error codes.
      # * ErrorCodes.NO_SUCH_RESOURCE if the resource iterator is
      #   empty or all resources have already been retrieved.
      def next_resource()
        if has_more_resources()
          result = @resources[@pos]
          @pos += 1
          return result
        else
          raise XMLDBApi::Base::XMLDBException.new(XMLDBApi::Base::ErrorCodes::NO_SUCH_RESOURCE), "There is no more resources to iterate over."
        end
      end
  end
end