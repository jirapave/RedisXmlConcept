require_relative "base/resource_set"
require_relative "base/xmldb_exception"
require_relative "base/error_codes"
require_relative "red_resource_iterator"
require "rubygems"
require "nokogiri"


module XMLDBApi
  class RedResourceSet < XMLDBApi::Base::ResourceSet
    
      def initialize()
        @resources = []
      end
     
      # Returns the Resource instance stored at the index specified
      # by index.
      # ==== Parameters
      # * +index+ - The index of the resource to retrieve.
      # ==== Return value
      # The Resource instance
      # ==== Raises
      # XMLDBApi::Base::XMLDBException with expected error codes.
      # * ErrorCodes.NO_SUCH_RESOURCE if the index is out of range for the set.
      def get_resource(index)
        if index < @resources.length and index >= 0
          return @resources[index]
        else
          raise XMLDBApi::Base::XMLDBException.new(XMLDBApi::Base::ErrorCodes::NO_SUCH_RESOURCE), "Resource with such a index does not exist, index=#{index}"
        end
      end

      # Adds a Resource instance to the set.
      # ==== Parameters
      # * +res+ - The Resource to add to the set.
      def add_resource(res)
        @resources << res
      end

      # Removes the Resource located at index from the set.
      # ==== Parameters
      # * +index+ - The index of the Resource instance to remove.
      def remove_resource(index)
        if index < @resources.length and index >= 0
          @resources.delete_at(index)
        end
      end

      # Returns an iterator over all Resource instances stored in the set.
      # ==== Return value
      # RedResourceIterator over all Resource instances in the set.
      def get_iterator()
        return XMLDBApi::RedResourceIterator.new(@resources)
      end
      
      # Returns a Resource containing an XML representation of all resources
      # stored in the set. 
      # XML representation of the Resource is as follows:
      # <?xml version="1.0" ?>
      # <resources>
      #   <resource id="id_of_the_resource">
      #     <root_element_of_the_resource>
      #       ....content....
      #     <root_element_of_the_resource>
      #   </resource>
      #   ....other resources....
      # </resources>
      # ==== Return value
      # A RedXmlResource instance containing an XML representation of all set members.
      def get_members_as_resource()
        #First we generate ID/name for the resource
        charset = %w{ 2 3 4 6 7 9 A C D E F G H J K M N P Q R T V W X Y Z}
        id = (0...16).map{ charset.to_a[rand(charset.size)] }.join
        
        # Each Resource has to have db_id and coll_id, we will try to determine db and collection
        # from the first resource in set, if it empty, dumy ids will be setted
        db_id = nil
        coll_id = nil
        doc_service = nil
        unless @resources.empty?
          res = @resources[0]
          db_id = res.db_id
          coll_id = res.coll_id
          doc_service = Transformer::DocumentService.new(db_id, coll_id)
        end
        #Then we will generate outer structure and iterate over all resources
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.resources do |res|
            @resources.each do |resource|
              #Now generate the structure of the resource based on their DOM
              unless resource.empty?
                id_res = resource.get_document_id
                res_node = nil
                res.resource("id" => "#{id_res}") do |content|
                  res_node = content.parent
                end
                #Now we have resource node in res_node variable, we can add_child with content of DOM in resource
                doc = resource.get_content_as_dom
                res_node.add_child(doc.root)
              end
            end
          end
        end
        if doc_service
          real_id = doc_service.get_possible_id
          return XMLDBApi::RedXmlResource.new(db_id, coll_id, id, real_id, builder.doc)
        end
        
        return XMLDBApi::RedXmlResource.new("1", "1", id, "1", builder.doc)
      end
     
      # Returns the number of resources contained in the set.
      # ==== Return value
      # The number of Resource instances in the set.
      def get_size()
        @resources.length
      end

      # Removes all Resource instances from the set.
      def clear()
        @resources.clear
      end
  end
end