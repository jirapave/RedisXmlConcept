require_relative "xml_transformer"
require_relative "../xml/document"
require_relative "../xml/sax_db_writer"
require_relative "../base_interface/db_interface"
require_relative "../transformer/key_builder"
require_relative "../xml_db_api/red_xml_resource"
require_relative "exceptions"
require "nokogiri"
require "observer"
class Notifier
end

module Transformer
  # Class represents a service used to work with whole XML files. It can saves them to the database, verify
  # their existence in a database and also retrives them.
  # This class is part of Observer pattern as Notifier, it get's notified by XML::SaxDocument class.
  class DocumentService < Notifier
    def initialize(env_id, coll_id)
      @xml_transformer = nil
      @db_interface = BaseInterface::DBInterface.instance
      @doc_key = Transformer::KeyBuilder.documents_key(env_id, coll_id)
      @env_info = Transformer::KeyBuilder.environment_info(env_id)
      @env_id = env_id
      @coll_id = coll_id
      @builder = nil
    end
    
    #This method gets called when a whole element or document information is retrived during
    #SAX parsing. This information is than saved to the database using XML::Transformer
    def update(value)
      if value.instance_of? Array
          #Document information are here, [version, encoding, standalone]
          key = @builder.info()
          field_values = []
          field_values << "name" << @doc_name
          field_values << "version" << value[0] if value[0] != nil
          field_values << "encoding" << value[1] if value[1] != nil
          field_values << "standalone" << value[2] if value[2] != nil
          @db_interface.add_to_hash(key, field_values, false)
      elsif value.instance_of? String
        #Root element name
        key = @builder.info()
        info = ["root", "#{value}"]
        @db_interface.add_to_hash(key, info, false)
      elsif value.instance_of? Hash
        #Element mapping is passed here
        key = @builder.elem_mapping_key()
        #We have to remap our hash to array
        field_values = []
        value.each do |key, value|
          field_values << key << value
        end
        @db_interface.add_to_hash(key, field_values, false)
      else
        #Element here
        @xml_transformer.save_node(value)
      end
    end
    
    # Used to create empty resource
    def get_possible_id()
      @result = @db_interface.increment_hash(@env_info, Transformer::KeyElementBuilder::ITERATOR_KEY, 1)
      
      #TODO This is needed in some very rare scenarios, i dont' know how it is possible that
      #if we increment the same key twice, we still have the same value, maybe some Redis bug. 
      # Currently occurs ONLY when all tests are run, if you run test alone, it works
      if @result == @last_result
        @result = @db_interface.increment_hash(@env_info, Transformer::KeyElementBuilder::ITERATOR_KEY, 1)
      end
      @last_result = @result
      return @result
    end
    
    #Method will save a given file to the given database under the given collection if it doensn't
    #already exist. SAX parser is used to parse an XML file.
    def save_document(file)
      if !File.file?(file)
        puts "Nejedna se o soubor"
        return false
      end
      file_name = File.basename(file)
      doc_id = get_possible_id
      result = @db_interface.add_to_hash_ne(@doc_key, file_name, doc_id)
      raise Transformer::MappingException, "Document with such a name already exist." unless result
      
      
      @builder = Transformer::KeyBuilder.new(@env_id, @coll_id, doc_id)
      @xml_transformer = Transformer::XMLTransformer.new(@builder)
      info = [file_name, doc_id]
      #Now file is saved, we have it's id and we can know proceed to parsing
      mapping = Transformer::MappingService.new(@builder)
      parser = Nokogiri::XML::SAX::Parser.new(XML::SaxDbWriter.new(self, mapping))
      @doc_name = file_name
      # parser = Nokogiri::XML::SAX::Parser.new(XML::ConsoleSaxDocument.new)
      
      #Main idea here is to SAX parser, events should be handled by SaxDocument, which
      #will prepare whole nodes and when the node ends, it will send event here (update method) so we
      #can use XmlTranformer to save it.
      h = @db_interface.find_value(@doc_key)
      @db_interface.transaction do
        parser.parse(File.open(File.absolute_path(file)))
      end
      h = @db_interface.find_value(@doc_key)
      puts "Document saved"
      true
    end
    
    #Finds a document under the specified database and collection, returns XML::Document with whole DOM loaded.
    def find_document(file_name)#:XML::Document
      file_id = get_document_id(file_name)
      
      if(file_id == nil)
        raise Transformer::MappingException, "Document with name #{file_name} not found."
        return nil
      end
      @builder = Transformer::KeyBuilder.new(@env_id, @coll_id, file_id)
      @xml_transformer = Transformer::XMLTransformer.new(@builder)
      return @xml_transformer.get_document(@builder)
    end
    
    def save_resource(resource)
      document = resource.get_content_as_dom
      if !resource.respond_to?(:get_content_as_sax)
        puts "Parameter is not a valid resource"
        return false
      end
      
      name = resource.get_document_id
      doc_id = resource.doc_id
      result = @db_interface.add_to_hash_ne(@doc_key, name, doc_id)
      raise Transformer::MappingException, "Document with such a name already exist." unless result
      
      
      @builder = Transformer::KeyBuilder.new(@env_id, @coll_id, doc_id)
      @xml_transformer = Transformer::XMLTransformer.new(@builder)
      info = [name, doc_id]
      #Now file is saved, we have it's id and we can know proceed to parsing
      mapping = Transformer::MappingService.new(@builder)
      handler = XML::SaxDbWriter.new(self, mapping)
      @doc_name = name
      
      @db_interface.transaction do
        resource.get_content_as_sax(handler)
      end
    end
    
    def get_resource(name)#:XML::Document
      file_id = get_document_id(name)
      
      if(file_id == nil)
        raise Transformer::MappingException, "Document with name #{name} not found."
        return nil
      end
      @builder = Transformer::KeyBuilder.new(@env_id, @coll_id, file_id)
      @xml_transformer = Transformer::XMLTransformer.new(@builder)
      document = @xml_transformer.get_document(@builder)
      return XMLDBApi::RedXmlResource.new(@env_id, @coll_id, name, file_id, document)
    end
    
    def get_document_id(name)
      doc_id = @db_interface.get_hash_value(@doc_key, name)
      return doc_id
    end
    
    def get_all_documents_ids()
      ids = @db_interface.get_all_hash_values(@doc_key)
      ids ||= []
      return ids
    end
    
    def get_all_documents_names()
      names =  @db_interface.get_all_hash_fields(@doc_key)
      names ||= []
      return names
    end
    
    def delete_document(name)
      #We have to delete <info, <emapping, <amapping, <content, and field in envId:collId:documents
      doc_id = get_document_id(name)
      return unless doc_id
      @builder = Transformer::KeyBuilder.new(@env_id, @coll_id, doc_id)
      del_keys = [@builder.content_key, @builder.info, @builder.elem_mapping_key, @builder.attr_mapping_key]
      @db_interface.transaction do
        @db_interface.delete_keys del_keys
        @db_interface.delete_from_hash(@doc_key, [name])
      end
    end
    
    def rename_document(document, name)
      #Verify that new name isn't already in database
      result = @db_interface.hash_value_exist?(@doc_key, name)
      raise Transformer::MappingException, "Document with such a name already exist." if result
      
      #Delete old document
      old_id = get_document_id(old_name)
      result = @db_interface.transaction do
        @db_interface.delete_from_hash(@doc_key, [old_name])
        @db_interface.add_to_hash_ne(@doc_key, name, old_id)
      end
      
      raise Transformer::MappingException, "Cannot delete old document's name, rename aborted." if result[0] != 1
      raise Transformer::MappingException, "Renaming failed." if result[1] != 1
      true
    end
    
    def rename_file(old_name, name)
      #Verify that new name isn't already in database
      result = @db_interface.hash_value_exist?(@doc_key, name)
      raise Transformer::MappingException, "Document with such a name already exist." if result
      result = @db_interface.hash_value_exist?(@doc_key, old_name)
      raise Transformer::MappingException, "Cannot rename, document #{old_name} doesn't exist." unless result
      
      #Delete old enevironment
      old_id = get_document_id(old_name)
      result = @db_interface.transaction do
        @db_interface.delete_from_hash(@doc_key, [old_name])
        @db_interface.add_to_hash_ne(@doc_key, name, old_id)
      end
      
      #Note: result may obtain some old return values from redis, we have to lookup at the end of result
      raise Transformer::MappingException, "Cannot delete old document's name, rename aborted." if result[-1] != 1
      raise Transformer::MappingException, "Renaming failed." if result[-2] != 1
      true
    end
    
    def update_document(file_name, document)
      
    end
    
    #Verifies if a document with a given name exist. Database and collection should be specified before using 
    #this method.
    def document_exist?(name)
      return @db_interface.hash_value_exist?(@doc_key, name)
    end
    
    private
    def ignore_field?(field_name)
      return true if field_name[0] == Transformer::KeyBuilder::HASH_SPECIAL_SEPARATOR
      return false
    end
    
  end
end