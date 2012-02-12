# require "rexml/parsers/xpathparser"
require_relative "xquery_controller"

@xquery_controller = XQuery::XQueryController.new(1, 1)
# @xquery_controller.get_results("doc(  \"catalog.xml\"  )(/prod:catalog/product[POSITION() < 3]/@dept)[1]")
# @xquery_controller.get_results("doc(  \"catalog.xml\"  )/prod:catalog/product[position() < 3]/@dept[1]") #hmm, to bude fakt zabava

query = "for $prod in doc(  \"catalog.xml\"  )/prod:catalog/product[position()<3]/@dept[1]  where $prod/@dept<=\"ACC\" order by $prod/name return $prod/name"
query = "doc(  \"catalog.xml\"  )/prod:catalog/product[position()<3]/@dept[1]"

# puts "query: #{query}"
@xquery_controller.get_results(query)

#TODO divide string by spaces NOT enclosed in any kind of brackets


# xpath_parser = REXML::Parsers::XPathParser.new
# result = xpath_parser.parse("/catalog/product[position() < 3]/@dept")
# puts result.inspect

# function = XQuery::Function.new(1, 1)
# function_string = "doc(  \"catalog.xml\"  )"
# result = function.process(function_string)
# 
# if(result.type == XQuery::TypedResult::DOC)
  # puts result.result
# end

