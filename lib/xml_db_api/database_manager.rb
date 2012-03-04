# package org.xmldb.api.modules;
#
# /*
# *  The XML:DB Initiative Software License, Version 1.0
# *
# *
# * Copyright (c) 2000-2001 The XML:DB Initiative.  All rights
# * reserved.
# *
# * Redistribution and use in source and binary forms, with or without
# * modification, are permitted provided that the following conditions
# * are met:
# *
# * 1. Redistributions of source code must retain the above copyright
# *    notice, this list of conditions and the following disclaimer.
# *
# * 2. Redistributions in binary form must reproduce the above copyright
# *    notice, this list of conditions and the following disclaimer in
# *    the documentation and/or other materials provided with the
# *    distribution.
# *
# * 3. The end-user documentation included with the redistribution,
# *    if any, must include the following acknowledgment:
# *       "This product includes software developed by the
# *        XML:DB Initiative (http://www.xmldb.org/)."
# *    Alternately, this acknowledgment may appear in the software itself,
# *    if and wherever such third-party acknowledgments normally appear.
# *
# * 4. The name "XML:DB Initiative" must not be used to endorse or
# *    promote products derived from this software without prior written
# *    permission. For written permission, please contact info@xmldb.org.
# *
# * 5. Products derived from this software may not be called "XML:DB",
# *    nor may "XML:DB" appear in their name, without prior written
# *    permission of the XML:DB Initiative.
# *
# * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
# * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# * DISCLAIMED.  IN NO EVENT SHALL THE APACHE SOFTWARE FOUNDATION OR
# * ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
# * USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
# * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# * SUCH DAMAGE.
# * ====================================================================
# *
# * This software consists of voluntary contributions made by many
# * individuals on behalf of the XML:DB Initiative. For more information
# * on the XML:DB Initiative, please see <http://www.xmldb.org/>.
# */
# import org.xmldb.api.base.*;

require_relative "red_database"
require_relative "base/xmldb_exception"
require_relative "base/error_codes"

# DatabaseManager is the entry point for the API and enables you to get the initial Collection references
# necessary to do anything useful with the API. DatabaseManager is intended to be provided as a concrete
# implementation in a particular programming language. Individual language mappings should define the exact
# syntax and semantics of its use.

module XMLDBApi
  class DatabaseManager
    URI_PREFIX = "xmldb:"
    @@databases = [XMLDBApi::RedDatabase.new("default")]
    @@properties = {}
    
    def self.get_databases()
      @@databases
    end

    def self.register_database(database)
      if database.get_name == nil or database.get_name == ""
        raise XMLDBException.new(XMLDBApi::Base::ErrorCodes::INVALID_DATABASE), "Cannot register database, name is not valid, name: #{database.get_name}"
      end
      
      @@databases.each do |db|
        if db.get_name == database.get_name
          raise XMLDBException.new(XMLDBApi::Base::ErrorCodes::INVALID_DATABASE), "Cannot register database, database with this name already exist, name: #{database.get_name}"
        end
      end
      
      @@databases << database
      
    end

    def self.deregister_database(database)
      @@databases.each_with_index do |db, index|
        if db.get_name == database.get_name
          @@databases.delete_at(index)
          break
        end
      end
    end

    def self.get_collection(uri)
      database = get_database(uri)
      parsed_uri = self.strip_URI(uri)
      return database.get_collection(parsed_uri["coll_path"])
    end

    def self.get_collection(uri, username = false, password = false)
      database = get_database(uri)
      parsed_uri = self.strip_URI(uri)
      return database.get_collection(parsed_uri["coll_path"])
    end

    def self.get_conformance_level(uri)
      database = get_database(uri)
      return database.get_conformance_level
    end

    def self.get_property(name)
      return @@properties[name]
    end

    def self.set_property (name, value)
      @@properties[name] = value
    end

    def self.get_database(uri)
      parsed_uri = self.strip_URI
      db_name = parsed_uri["db_name"]
      database = find_db(db_name)
      raise XMLDBException.new(XMLDBApi::Base::ErrorCodes::NO_SUCH_DATABASE), "Database for the given URI is not registered" unless database
      return database
    end
    
    def self.strip_URI(uri)
      result = {}
      parts = uri.split("//")
      if parts[0].length != 2 or parts[0].split(":")[0] != URI_PREFIX
        raise XMLDBException.new(XMLDBApi::Base::ErrorCodes::INVALID_URI), "URI is not valid, no xmldb: prefix found"
      end
      result["prefix"] = parts[0]
      result["db_name"] = parts[1]
      
      path = parts[1]
      if path.split(":").length == 2
        #Cut host:port/path/to/collection to path/to/collection 
        path = path.split("/")[1..-1].join("/")
      end
      
      result["coll_path"] = path
      result
    end
    
    def find_db(name)
      result = nil
      @@databases.each_with_index do |db, index|
        if db.get_name == name
          result = db
          break
        end
      end
      result
    end
  end
end