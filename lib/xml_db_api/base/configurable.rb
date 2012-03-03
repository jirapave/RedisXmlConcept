# package org.xmldb.api.base;
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

require_relative "error_codes"

# /**
# * Provides the ability to configure properties about an object.
# */
module XMLDBApi
  module Base
    class Configurable
      # /**
      # * Returns the value of the property identified by <code>name</code>.
      # *
      # * @param name the name of the property to retrieve.
      # * @return the property value or null if no property exists.
      # * @exception XMLDBException with expected error codes.<br />
      # *  <code>ErrorCodes.VENDOR_ERROR</code> for any vendor
      # *  specific errors that occur.<br />
      # */
      def get_property(name)
        raise XMLDBApi::Base::ErrorCodes::NotImplemetedError
      end

      # /**
      # * Sets the property <code>name</code> to have the value provided in
      # * <code>value</code>.
      # *
      # * @param name the name of the property to set.
      # * @param value the value to set for the property.
      # * @exception XMLDBException with expected error codes.<br />
      # *  <code>ErrorCodes.VENDOR_ERROR</code> for any vendor
      # *  specific errors that occur.<br />
      # */
      def set_property(name, value)
        raise XMLDBApi::Base::ErrorCodes::NotImplemetedError
      end
    end
  end
end