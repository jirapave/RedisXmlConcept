require_relative "../lib/xquery/xquery_controller"

@xquery_controller = XQuery::XQueryController.new(1, 1)

query = "for $prod in doc(  \"catalog.xml\"  )/prod:catalog/product[position()<3]/@dept[1]  where $prod/@dept<=\"ACC\" order by $prod/name return $prod/name"
query = "doc(  \"catalog.xml\"  )/prod:catalog/product[position()<3]/@dept[@dept = \"ACC\"]"

# puts "query: #{query}"
@xquery_controller.get_results(query)




