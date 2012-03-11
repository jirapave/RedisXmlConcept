# require "../lib/xquery_module/parser_extension/XQueryParser"
# str = XQueryParser::Parser.parse_xquery("for $prod in doc( \"catalog.xml\" ) / catalog/product/number  [ . = 333] let $name :=  $ prod/name where $prod/@dept=\"ACC\" order by $x/title return $name")
# puts str

puts "ehm"
require_relative "../lib/xquery_module/xquery/query_parser"
puts "will"
XQuery::QueryParser.parse_query("for $prod in doc( \"catalog.xml\" ) / catalog/product/number  [ . = 333] let $name :=  $ prod/name where $prod/@dept=\"ACC\" order by $x/title return $name")
# XQuery::QueryParser.parse_query("for $prod in doc( \"catalog.xml\" ) / catalog/product/number  [ . = 333]  where $prod/@dept=\"ACC\"  return $name")


exit
require_relative "../lib/xquery_module/grammar/expression/expression_handle"

require 'rubygems'
require 'treetop'
require_relative "../lib/xquery_module/grammar/grammar_extensions"
require_relative "../lib/xquery_module/grammar/expression/expression_extensions"

puts 'Loaded Treetop with no problems...'

Treetop.load '../lib/xquery_module/grammar/XQuery'
puts 'Loaded xquery grammar with no problems...'

parser = XQueryParser.new
puts "parser loaded"
what_you_said = "doc(  \"catalog.xml\" )/catalog/product/number[. = 333]"
what_you_said = "for $prod in doc(  \"catalog.xml\" )/catalog/product/number[. = 333] return <e>"
what_you_said = "for $prod in doc(  \"catalog.xml\" )/catalog/ product /number [ . = 333 ] return <e />"
what_you_said = "for $prod in doc(\"catalog.xml\")/catalog/product/number[.=333] let $name:=$prod/name where $prod/name>3 return $prod"#ee
what_you_said = "for $prod in doc(\"catalog.xml\")/catalog/product/number[. = 333]"
what_you_said = "let $name := $prod/name"
what_you_said = "where $prod/@dept = \"ACC\""
what_you_said = "order by $x/title"
what_you_said = "for $prod in doc(\"catalog.xml\")/catalog/product / number [. = 333] let $name := $prod/name  where $prod/@dept = \"ACC\"    order by $x/title      return $name"
# what_you_said = "for $prod in doc(\"catalog.xml\")/catalog/product/number[. = 333] riptide"
# what_you_said = "for $prod in doc(  \"catalog.xml\" )/catalog/ product /number [ . = 333 ]      where $prod/name > 3      return <e />"
# what_you_said = "doc(  \"catalog.xml\" )/catalog/product/number[. = 333]"
# what_you_said = "let $name := $prod/name"
# what_you_said = "for $prod in doc(  \"catalog.xml\" )/catalog/ product /number [ . = 333 ]            \n let "



what_you_said = "for $prod in doc(\"catalog.xml\")/catalog/product/number[.=333] let $name:=$prod/name where $prod/@dept=\"ACC\" order by $x/title return $name"
what_you_said = "for $prod in doc(\"catalog.xml\")/catalog/product/number[.=333] let $name:=$prod/name where $prod/@dept=\"ACC\" order by $x/title return $name"
what_you_said = "for $prod in doc(\"catalog.xml\")/catalog/product/number[.=333] let $name:=$prod/name where $prod/@dept=\"ACC\" order by $x/title return $name"
what_you_said = "for $prod in doc(\"catalog.xml\")/catalog/product/number[.=333] let $name:=$prod/name return $name"
what_you_said = "let $name:=$prod/name"

if result=parser.parse(what_you_said, :root => :LetClause)
# if result=parser.parse(what_you_said)
  puts "I say yes! I understand!"
  

  puts "result elemL: #{result.elements.length}"

  puts result.type
  # puts result.inspect
  
  puts result.inspect
  
  handle = XQuery::ExpressionHandle.new(result)
  puts handle.type
  # puts handle.raw.return_expr.text_value
  # puts handle.raw.for_let_clauses
  
  puts handle.parts.length
  
  
  puts result.type


else
  puts "I say no, I don't understand."
  unless parser.terminal_failures.empty?
    puts parser.failure_reason
  else
    puts "I had a problem with line #{parser.failure_line} column #{parser.index+1}"
    puts "To be honest, I was not expecting you to say anything more."
  end
end