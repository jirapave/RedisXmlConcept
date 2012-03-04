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
#
# DatabaseManager is the entry point for the API and enables you to get the initial Collection references
# necessary to do anything useful with the API. DatabaseManager is intended to be provided as a concrete
# implementation in a particular programming language. Individual language mappings should define the exact
# syntax and semantics of its use.

module XMLDBApi
  class DatabaseManager
    URI_PREFIX = "xmldb:"
    def self.get_databases()
    end

    def self.register_database(database)
      # if ((database.getName() == null) || (database.getName().equals(""))) {
      # throw new XMLDBException(ErrorCodes.INVALID_DATABASE);
      # }
      #
      # databases.put(database.getName(), database);
      #

    end

    def self.deregister_database(database)

    end

    def self.get_collection(uri)

    end

    def self.get_collection(uri, username, password)
      #      Database db = getDatabase(uri);

      #      uri = stripURIPrefix(uri);

      #      return (org.xmldb.api.base.Collection) db.getCollection(uri, username,
      #         password);
    end

    def self.get_conformance_level(uri)

    end

    def self.get_property(name)

    end

    def self.set_property (name, value)

    end

    def self.get_database(uri)
      # if (!uri.startsWith(URI_PREFIX)) {
      # throw new XMLDBException(ErrorCodes.INVALID_URI);
      # }
      #
      # int end = uri.indexOf(":", URI_PREFIX.length());
      # if (end == -1) {
      # throw new XMLDBException(ErrorCodes.INVALID_URI);
      # }
      #
      # String databaseName = uri.substring(URI_PREFIX.length(), end);
      #
      # Database db = (Database) databases.get(databaseName);
      # if (db == null) {
      # throw new XMLDBException(ErrorCodes.NO_SUCH_DATABASE);
      # }
      #
      # return db;
    end

    # /**
    # * Removes the URI_PREFIX from the front of the URI. This is so the database
    # * can focus on handling its own URIs.
    # *
    # * @param uri The full URI to strip.
    # * @return The database specific portion of the URI.
    # */
    private

    def strip_URI_prefix(uri)
      # if (!uri.startsWith(URI_PREFIX)) {
      # throw new XMLDBException(ErrorCodes.INVALID_URI);
      # }
      #
      # String dbURI = uri.substring(URI_PREFIX.length(), uri.length());
      # return dbURI;
    end
  end
end