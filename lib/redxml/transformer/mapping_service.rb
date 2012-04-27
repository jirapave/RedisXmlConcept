require_relative "../base_interface/db_interface"
require_relative "exceptions"
require_relative "key_builder"

module Transformer
  # Class is used to map environment, collection, document, element and attribute names to their 
  # ids and reverse.
  class MappingService
    
    # String represents field name of the result under which the environment id or name can be found
    ENV_KEY = "env"
    # String represents field name of the result under which the collection id or name can be found
    COLL_KEY = "coll"
    # String represents field name of the result under which the document id or name can be found
    DOC_KEY = "doc"
    
    # Accessor fot the KeyBuilder instance which is used to determine where the mapping can be found
    attr_accessor :key_builder
    
    #--
    #db_interface insttance is obtained in almost each method, unfortunately, we are unable to create
    #class variable of db_interfacem, because by the time we call static method, instance is not ready
    #yet and error is produced
    #++
    
    # Creates new instance of MappingService using KeyBuilder as a parameter
    # ==== Parameters
    # * +key_builder+ - KeyBuilder instance used to determien where to find and create mappings
    def initialize(key_builder)
      #KeyElementBuilder will be created here and used as a basis for mapping of elements and attributes
      @key_builder = key_builder
      @db_interface = BaseInterface::DBInterface.instance
      @elem_hash = @db_interface.find_value(@key_builder.elem_mapping_key)
      @elem_hash.reject! { |field, value| field[0] == "<" } if @elem_hash
      @attr_hash = @db_interface.find_value(@key_builder.attr_mapping_key)
      @attr_hash.reject! { |field, value| field[0] == "<" } if @attr_hash
      @elem_hash ||= {}
      @attr_hash ||= {}
    end
    
    # Method will load mappings from the database. Sometimes it is needed to get new mappings because they
    # were changed.
    def refresh_hash_mapping()
      @elem_hash = @db_interface.find_value(@key_builder.elem_mapping_key)
      @elem_hash.reject! { |field, value| field[0] == "<" } if @elem_hash
      @attr_hash = @db_interface.find_value(@key_builder.attr_mapping_key)
      @attr_hash.reject! { |field, value| field[0] == "<" } if @attr_hash
    end
    
    # Creates new id for the given element name. If the element name already had ID, new ID is not used
    # and element's old ID remains unchanged. ID is created in the document specified in key_builder
    # ==== Parameters
    # * +elem_name+ - Name of the element for which the ID should be created
    # ==== Return value
    # String with the ID of the element or false if element already had ID
    def create_elem_mapping(elem_name)
      #return @elem_hash[elem_name] if @elem_hash[elem_name]
      elem_id = @db_interface.increment_hash(@key_builder.elem_mapping_key, Transformer::KeyElementBuilder::ITERATOR_KEY, 1, true)
      #result = @db_interface.add_to_hash_ne(@key_builder.elem_mapping_key, elem_name, elem_id, true)
      @db_interface.add_to_hash(@key_builder.elem_mapping_key, [elem_name, elem_id], true)
      result = true
      if result
        @elem_hash[elem_name] = elem_id
        return elem_id
      else
        puts "result in create_elem_mapping = #{result}, hofnota je =  #{@elem_hash[elem_name]}"
      end
      false
    end
    
    # Creates new id for the given attribue name. If the attribute name already had ID, new ID is not used
    # and attribute's old ID remains unchanged. ID is created in the document specified in key_builder
    # ==== Parameters
    # * +attr_name+ - Name of the attribute for which the ID should be created
    # ==== Return value
    # String with the ID of the attribute or false if attribute already had ID
    def create_attr_mapping(attr_name)
      #return @attr_hash[attr_name] if @attr_hash[attr_name]
      attr_id = @db_interface.increment_hash(@key_builder.attr_mapping_key, Transformer::KeyElementBuilder::ITERATOR_KEY, 1, true)
      #result = @db_interface.add_to_hash_ne(@key_builder.attr_mapping_key, attr_name, attr_id, true)
      result = true
      if result
        @db_interface.add_to_hash(@key_builder.attr_mapping_key, [attr_name, attr_id], true)
        @attr_hash[attr_name] = attr_id
        return attr_id
      end
      false
    end

    # Obtains id for the given environment name.
    # ==== Parameters
    # * +env_name+ - Name of the environment for which the ID should be retrieved
    # ==== Return value
    # String with the ID of the environment
    # ==== Raises
    # Transformer::MappingException - If environment does not have id = does not exist
    def self.map_env(env_name)
      env_id = self.map_to_id(Transformer::KeyBuilder.environments_key, env_name, "Environment")
      env_id
    end
    
    # Obtains id for the given collection name.
    # ==== Parameters
    # * +env_id+ - ID of the environment in which the collection is located
    # * +coll_name+ - Name of the collection for which the ID should be retrieved
    # ==== Return value
    # String with the ID of the collection
    # ==== Raises
    # Transformer::MappingException - If collection does not have id = does not exist, or 
    # environment with such an ID does not exist
    def self.map_coll(env_id, coll_name)
      coll_id = self.map_to_id(Transformer::KeyBuilder.collections_key(env_id), coll_name, "Collection")
      coll_id
    end
    
    # Obtains id for the given document name.
    # ==== Parameters
    # * +env_id+ - ID of the environment in which the document is located
    # * +coll_id+ - ID of the collection in which the document is located
    # * +doc_name+ - Name of the document for which the ID should be retrieved
    # ==== Return value
    # String with the ID of the document
    # ==== Raises
    # Transformer::MappingException - If document does not have id = does not exist, or 
    # environment (or collection) with such an ID does not exist
    def self.map_doc(env_id, coll_id, doc_name)
      doc_id = self.map_to_id(Transformer::KeyBuilder.documents_key(env_id, coll_id), doc_name, "Document")
      doc_id
    end

    # Obtains IDs of the environment and collection in the form of hash.
    # ==== Parameters
    # * +env_name+ - Name of the environment for which the ID should be retrieved
    # * +coll_name+ - Name of the collection located in environment with the name env_name 
    #                 for which the ID should be retrieved
    # ==== Return value
    # Hash with the IDs saved under fields with names based on ENV_KEY and COL_KEY constants
    # ==== Raises
    # Transformer::MappingException - If the environment or collection does not exist
    def self.map_env_coll(env_name, coll_name)
      env_id = self.map_to_id(Transformer::KeyBuilder.environments_key, env_name, "Environment")
      coll_id = self.map_to_id(Transformer::KeyBuilder.collections_key(env_id), coll_name, "Collection")
      result = {ENV_KEY => env_id, COLL_KEY => coll_id}
      result
    end
    
    # Obtains IDs of the environment, collection and document in the form of hash.
    # ==== Parameters
    # * +env_name+ - Name of the environment for which the ID should be retrieved
    # * +coll_name+ - Name of the collection located in environment with the name env_name 
    #                 for which the ID should be retrieved
    # * +doc_name+ - Name of the document for which the ID should be retrieved located in 
    #                the environment and collection with the names specified by previous parameters
    # ==== Return value
    # Hash with the IDs saved under fields with names based on ENV_KEY, COL_KEY and DOC_KEY constants
    # ==== Raises
    # Transformer::MappingException - If the environment, collection or document does not exist
    def self.map_env_coll_doc(env_name, coll_name, doc_name)
      env_id = self.map_to_id(Transformer::KeyBuilder.environments_key, env_name, "Environment")
      coll_id = self.map_to_id(Transformer::KeyBuilder.collections_key(env_id), coll_name, "Collection")
      doc_id = self.map_to_id(Transformer::KeyBuilder.documents_key(env_id, coll_id), doc_name, "Document")
      
      result = {ENV_KEY => env_id, COLL_KEY => coll_id, DOC_KEY => doc_id}
      result
    end

    # Obtains IDs of the element located in the document specified in by key_builder
    # ==== Parameters
    # * +elem_name+ - Name of the element for which the ID should be retrieved
    # ==== Return value
    # String with the ID of the element
    # ==== Raises
    # Transformer::MappingException - If the element does not have ID, it may occur if elem_hash is not actual
    # and does not contain ID. Refresh could help.
    def map_elem_name(elem_name)
      elem_id = @elem_hash[elem_name]
      raise Transformer::MappingException, "Element #{elem_name} does not have mapping to id" unless elem_id
      elem_id
    end

    # Obtains IDs of the attribute located in the document specified in by key_builder
    # ==== Parameters
    # * +attr_name+ - Name of the attriute for which the ID should be retrieved
    # ==== Return value
    # String with the ID of the attribute
    # ==== Raises
    # Transformer::MappingException - If the attriute does not have ID, it may occur if attr_hash is not actual
    # and does not contain ID. Refresh could help.
    def map_attr_name(attr_name)
      attr_id = @attr_hash[attr_name]
      raise Transformer::MappingException, "Attribute #{attr_name} does not have mapping to id" unless attr_id
      attr_id
    end

    # Obtains ame for the given environment ID.
    # ==== Parameters
    # * +env_id+ - ID of the environment for which the name should be retrieved
    # ==== Return value
    # String with the name of the environment
    # ==== Raises
    # Transformer::MappingException - If environment does not have name = ID does not exist
    def self.unmap_env(env_id)
      env_mapping_key = Transformer::KeyBuilder.environments_key
      env_name = self.unmap_hash(env_mapping_key, env_id)
      env_name
    end

    # Obtains name for the given collection ID.
    # ==== Parameters
    # * +env_id+ - ID of the environment in which the collection is located
    # * +coll_id+ - ID of the collection for which the name should be retrieved
    # ==== Return value
    # String with the name of the collection
    # ==== Raises
    # Transformer::MappingException - If collection does not have name = ID does not exist, or 
    # environment with such an ID does not exist
    def self.unmap_coll(env_id, coll_id)
      coll_mapping_key = Transformer::KeyBuilder.collections_key(env_id)
      coll_name = self.unmap_hash(coll_mapping_key, coll_id)
      coll_name
    end
    
    # Obtains name for the given document name.
    # ==== Parameters
    # * +env_id+ - ID of the environment in which the document is located
    # * +coll_id+ - ID of the collection in which the document is located
    # * +doc_id+ - ID of the document for which the name should be retrieved
    # ==== Return value
    # String with the name of the document
    # ==== Raises
    # Transformer::MappingException - If document does not have name = ID does not exist, or 
    # environment (or collection) with such an ID does not exist
    def self.unmap_doc(env_id, coll_id, doc_id)
      doc_mapping_key = Transformer::KeyBuilder.documents_key(env_id, coll_id)
      doc_name = self.unmap_hash(doc_mapping_key, doc_id)
      doc_name
    end

    # Obtains names of the environment and collection in the form of hash.
    # ==== Parameters
    # * +env_id+ - ID of the environment for which the name should be retrieved
    # * +coll_id+ - ID of the collection located in environment with the ID env_id 
    #                 for which the name should be retrieved
    # ==== Return value
    # Hash with the names saved under fields with names based on ENV_KEY and COL_KEY constants
    # ==== Raises
    # Transformer::MappingException - If the environment or collection does not exist
    def self.unmap_env_coll(env_id, coll_id)
      env_mapping_key = Transformer::KeyBuilder.environments_key
      env_name = self.unmap_hash(env_mapping_key, env_id)
      
      coll_mapping_key = Transformer::KeyBuilder.collections_key(env_id)
      coll_name = self.unmap_hash(coll_mapping_key, coll_id)
      
      result = {ENV_KEY => env_name, COLL_KEY => coll_name}
      result
    end

    # Obtains names of the environment, collection and document in the form of hash.
    # ==== Parameters
    # * +env_id+ - ID of the environment for which the name should be retrieved
    # * +coll_id+ - ID of the collection located in environment with the ID env_id 
    #                 for which the name should be retrieved
    # * +doc_id+ - ID of the document for which the name should be retrieved located in 
    #                the environment and collection with the names specified by previous parameters
    # ==== Return value
    # Hash with the names saved under fields with names based on ENV_KEY, COL_KEY and DOC_KEY constants
    # ==== Raises
    # Transformer::MappingException - If the environment, collection or document does not exist
    def self.unmap_env_coll_doc(env_id, coll_id, doc_id)
      env_mapping_key = Transformer::KeyBuilder.environments_key
      env_name = self.unmap_hash(env_mapping_key, env_id)
      
      coll_mapping_key = Transformer::KeyBuilder.collections_key(env_id)
      coll_name = self.unmap_hash(coll_mapping_key, coll_id)
      
      doc_mapping_key = Transformer::KeyBuilder.documents_key(env_id, coll_id)
      doc_name = self.unmap_hash(doc_mapping_key, doc_id)
      
      result = {ENV_KEY => env_name, COLL_KEY => coll_name, DOC_KEY => doc_name}
      result
    end

    # Obtains name of the element located in the document specified in by key_builder
    # ==== Parameters
    # * +elem_id+ - ID of the element for which the name should be retrieved
    # ==== Return value
    # String with the name of the element
    # ==== Raises
    # Transformer::MappingException - If the element does not have name, it may occur if elem_hash is not actual
    # and does not contain ID. Refresh could help.
    def unmap_elem_name(elem_id)
      elem_name = Transformer::MappingService.find_hash_key(@elem_hash, elem_id)
      raise Transformer::MappingException, "Mappping for element with id:#{elem_id} does not exist" unless elem_name
      elem_name
    end

    # Obtains name of the attribute located in the document specified in by key_builder
    # ==== Parameters
    # * +attr_id+ - ID of the attriute for which the name should be retrieved
    # ==== Return value
    # String with the name of the attribute
    # ==== Raises
    # Transformer::MappingException - If the attriute does not have name, it may occur if attr_hash is not actual
    # and does not contain ID. Refresh could help.
    def unmap_attr_name(attr_id)
      attr_name = Transformer::MappingService.find_hash_key(@attr_hash, attr_id)
      raise Transformer::MappingException, "Mapping for attribute with id:#{attr_id} does not exist" unless attr_name
      attr_name
    end
    
    private
    
    def self.map_to_id(key, name, description)#:nodoc:
      db_interface = BaseInterface::DBInterface.instance
      id = db_interface.get_hash_value(key, name)
      raise Transformer::MappingException, "#{description} #{name} does not have mapping to id = does not exist" unless id
      id
    end
    
    def self.unmap_hash(hash_key, id)#:nodoc:
      db_interface = BaseInterface::DBInterface.instance
      mapping_hash = db_interface.find_value(hash_key)
      name = self.find_hash_key(mapping_hash, id)
      raise Transformer::MappingException, "Environment #{id} does not have mapping to name = does not exist" unless name
      name
    end
    
    def self.find_hash_key(hash, id)#:nodoc:
      name = nil
      hash.each do |field, value|
        if value == id and field != "<iterator>"
          name = field 
          break
        end
      end
      name
    end
    
  end
end