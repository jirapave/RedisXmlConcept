require_relative "xml_transformer"
require_relative "../xml/document"
require_relative "../xml/sax_document"
require_relative "../base_interface/db_interface"
require "nokogiri"
require "observer"
class Notifier
end

module Transformer
  #Class represents a service used to work with whole XML files. It can saves them to the database, verify
  #their existence in a database and also retrives them.
  #This class is part of Observer pattern as Notifier, it get's notified by XML::SaxDocument class.
  class DocumentService < Notifier
    def initialize(env_id, coll_id)
      @xml_transformer = nil
      @db_interface = BaseInterface::DBInterface.instance
      @doc_key = Transformer::KeyBuilder.documents_key(env_id, coll_id)
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
        puts "Mapovani ulozena pod klicem: #{key}"
        @db_interface.add_to_hash(key, field_values, false)
      else
        #Element here
        @xml_transformer.save_node(value)
      end
    end
    
    #Method will save a given file to the given database under the given collection if it doensn't
    #already exist. SAX parser is used to parse an XML file.
    def save_document(file)
      if !File.file?(file)
        puts "Nejedna se o soubor"
        return false
      end
      
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
      
      @db_interface.commit_after do
        parser.parse(File.open(File.absolute_path(file)))
      end
      
      puts "Document saved"
      true
    end
    
    def all_documents(database=-1,collection=-1)
      
    end
    
    #Finds a document under the specified database and collection, returns XML::Document with whole DOM loaded.
    def find_document(file_name)#:XML::Document
      file_id = document_exist?(file_name)
      
      if(file_id == nil)
        puts "Document with name #{file_name} not found."
        return nil
      end
      
      @builder = Transformer::KeyBuilder.new(@env_id, @coll_id, file_id)
      @xml_transformer = Transformer::XMLTransformer.new(@builder)
      return @xml_transformer.find_node(@builder)
    end
      
    def remove_document(document)
      
    end
    
    def remove_file(file_name)
      
    end
    
    def rename_document(document, name)
      
    end
    
    def rename_file(file_name)
      
    end
    
    def update_document(file_name, document)
      
    end
    
    #Verifies if a document with a given name exist. Database and collection should be specified before using 
    #this method.
    def document_exist?(file_name)
      all_files = @db_interface.find_value(@doc_key)
      
      #debug purposes
      puts "All files in this collection:"
      if all_files != nil 
        all_files.each do |key, value|
          puts "file #{key}, id: #{value}"
        end
      end
      #debug purposes
      
      file_id = nil
      if all_files != nil 
        all_files.each do |key, value|
          if(key == file_name)
            file_id = value
            break
          end
        end
      end
      
      return file_id
    end
    
  end
end