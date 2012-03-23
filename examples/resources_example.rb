require_relative "../lib/redxml"

db = XMLDBApi::RedDatabase.new("db_name")
XMLDBApi::DatabaseManager.register_database(db)

coll = db.create_collection("root_collection")

# Now lets create some resources with different methods
# We have to specify oth parameters, if the first is nil, name is generated
# Created resource is empty and CANNOT be saved in database
res = coll.create_resource("name", XMLDBApi::RedXmlResource::TYPE)

# Now after content is set we can store resource in database
res.set_content("<root xmlns:a=\"http://www.some.com/book\"><a:book>Hyperion</a:book></root>")

# Now it's in the database
coll.store_resource(res)

res = coll.create_resource("another", XMLDBApi::RedXmlResource::TYPE)

# Lets try SAX
file = "#{__FILE__}/../books2.xml"
handler = res.set_content_as_sax
parser = Nokogiri::XML::SAX::Parser.new(handler)
# And now parser will generate events from XML document and handler will create DOM in resource
parser.parse(File.open(File.absolute_path(file)))
coll.store_resource(res)

res = coll.create_resource("last", XMLDBApi::RedXmlResource::TYPE)

# Of course we can use DOM
doc = Nokogiri::XML("<root><book>First</book></root>")
res.set_content_as_dom(doc)
coll.store_resource(res)

# Now how can we get our resources back from database?
res = coll.get_resource("last")

# Resources are lazy loaded, now we have many options how to obtain content and their
# usage greatly differ based on your requirements. For example:

# This will get me DOM document, instance of Nokogiri::XML::Document
doc = res.get_content_as_dom

# Or we can get plain string
text = res.get_content

# It's obvious that once the content of resource was loaded, any furthure requests for
# content going directly to memory, no database requests are required

# At last let's take a look at this interesting option:
res = coll.get_resource("another")

# Now we would like to somehow get content from the database but we don't want to
# use our memory, because that file could be 1 GB large, we can use SAX in that scenario.
# First it's obviously up to you how you implement your SAX handler, you can send events 
# through the network using HTTP requests for example
handler = XML::SaxDomCreator.new(res)
res.get_content_as_sax(handler) # SAX events are generated into handler

puts "resource content: #{res.get_content_as_dom}"
