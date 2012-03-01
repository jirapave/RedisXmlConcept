require_relative "xml_transformer"
require_relative "../xml/document"
require_relative "../xml/sax_document"
require_relative "../base_interface/db_interface"
require_relative "exceptions"
require "nokogiri"
require "observer"
class Notifier
end

module Transformer
  #Class represents a service used to work with whole XML files. It can saves them to the database, verify
  #their existence in a database and also retrives them.
  #This class is part of Observer pattern as Notifier, it get's notified by XML::SaxDocument class.
  class DocumentService < Notifier
    def initialize()
      @xml_transformer = nil
      @db_interface = BaseInterface::DBInterface.instance
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
          puts "Saving document info..."
          @db_interface.add_to_hash(key, field_values, false)
      elsif value.instance_of? String
        #Root element name
        key = @builder.info()
        puts "Saving string values...document info, root_name: #{value}"
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
    
    #Method will save a given file to the given database under the given collection if it doensn't
    #already exist. SAX parser is used to parse an XML file.
    def save_document(env_id, coll_id, file)
      if !File.file?(file)
        puts "Nejedna se o soubor"
        return false
      end
      
      @doc_key = Transformer::KeyBuilder.documents_key(env_id, coll_id)
      @env_id = env_id
      @coll_id = coll_id
      
      file_name = File.basename(file)
      puts "Does document exist?"
      doc_id = @db_interface.increment_hash(@doc_key, Transformer::KeyElementBuilder::ITERATOR_KEY, 1)
      result = @db_interface.add_to_hash_ne(@doc_key, file_name, doc_id)
      raise MappingException, "Document with such a name already exist." unless result
      
      puts "No, proceeding with saving..."
      
      @builder = Transformer::KeyBuilder.new(@env_id, @coll_id, doc_id)
      @xml_transformer = Transformer::XMLTransformer.new(@builder)
      info = [file_name, doc_id]
      puts "Saving document: #{info.inspect}"
      #Now file is saved, we have it's id and we can know proceed to parsing
      mapping = Transformer::MappingService.new(@builder)
      parser = Nokogiri::XML::SAX::Parser.new(XML::SaxDocument.new(self, mapping))
      @doc_name = file_name
      # parser = Nokogiri::XML::SAX::Parser.new(XML::ConsoleSaxDocument.new)
      
      #Main idea here is to SAX parser, events should be handled by SaxDocument, which
      #will prepare whole nodes and when the node ends, it will send event here (update method) so we
      #can use XmlTranformer to save it.
      puts "Parsing in progress..."
      
      @db_interface.transaction do
        parser.parse(File.open(File.absolute_path(file)))
      end
      
      puts "Document saved"
      true
    end
    
    #Finds a document under the specified database and collection, returns XML::Document with whole DOM loaded.
    def find_file(file_name, db_name, coll_name)#:XML::Document
      @doc_key = Transformer::KeyBuilder.documents_key(db_name, coll_name)
      @env_id = db_name
      @coll_id = coll_name
      
      file_id = get_document_id(file_name)
      
      if(file_id == nil)
        raise Transformer::MappingException, "Document with name #{file_name} not found."
        return nil
      end
      @builder = Transformer::KeyBuilder.new(@env_id, @coll_id, file_id)
      @xml_transformer = Transformer::XMLTransformer.new(@builder)
      return @xml_transformer.find_node(@builder)
    end
    
    def get_document_id(name)
      doc_id = @db_interface.get_hash_value(@doc_key, name)
      return doc_id
    end
    
    def get_all_documents_ids()
      #Remember there is a field <iterator> which we have to exclude
      iter_id = @db_interface.get_hash_value(@doc_key, Transformer::KeyBuilder::ITERATOR_KEY)
      #We have to exclude first occurence of iter_id
      result = @db_interface.get_all_hash_values(@doc_key)
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
    
    def get_all_documents_names()
      names =  @db_interface.get_all_hash_fields(@doc_key)
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
    
    def delete_document(name)
      #We have to delete <info, <emapping, <amapping, <content, and field in envId:collId:documents
      doc_id = get_document_id(name)
      raise Transformer::MappingException, "Document with such a name doesn't exist." unless doc_id
      @builder = Transformer::KeyBuilder.new(@env_id, @coll_id, doc_id)
      del_keys = [@builder.content_key, @builder.info, @builder.elem_mapping_key, @builder.attr_mapping_key]
      @db_interface.transaction do
        @db_interface.delete_keys del_keys
        @db_interface.delete_from_hash(@doc_key, name)
      end
    end
    
    def rename_document(document, name)
      #Verify that new name isn't already in database
      result = @db_interface.hash_value_exist?(@doc_key, name)
      raise Transformer::MappingException, "Document with such a name already exist." if result
      
      #Delete old document
      old_id = get_document_id(old_name)
      result = @db_interface.transaction do
        @db_interface.delete_from_hash(@doc_key, old_name)
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
        @db_interface.delete_from_hash(@doc_key, old_name)
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
    
  end
end