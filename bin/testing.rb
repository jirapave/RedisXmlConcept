# require_relative "../lib/xml/node"
# require_relative "../lib/xml/doc_type"
# require_relative "../lib/xml/element"
# require_relative "../lib/xml/document"
# require_relative "../lib/xml/text_content"
# 
# doc_type = XML::DocType.new("internal_subset1", "name1", "public Id", "system id")
# 
# doc = XML::Document.new(doc_type, "UTF-8", "file name1", nil, "true", "1.0", "<?xml standalone=\"yes\" version=\"1.0\"?>")
# 
# root = XML::Element.new("root1", "key", nil, doc)
# doc.root_element = root
# 
# elem = XML::Element.new("elem1", "key", nil, root)
# root.descendants << elem
# text = XML::TextContent.new(nil, "text content 1", nil)
# elem.descendants << text
# elem1 = XML::Element.new("sub", "key", nil, elem)
# elem.descendants << elem1
# text = XML::TextContent.new(nil, "text content sub", nil)
# elem1.descendants << text
# text = XML::TextContent.new(nil, "text content 1", nil)
# elem.descendants << text
# 
# 
# puts doc.to_s

require_relative "../lib/base_interface/db_interface"
require_relative "../lib/transformer/key_element_builder"
# require_relative "../lib/transformer/key"

db = BaseInterface::DBInterface.instance
# hash = db.find_value("1::1::1::catalog<attributes")
# puts hash.inspect
key = Transformer::Key.create(1, 1, 1).root("catalog").elem!("book", 1).elem!("description", 0)
puts key
desc = db.find_value(key)
puts desc

key = Transformer::Key.create(1, 1, 1).root("catalog").elem!("book", 1).elem!("description", 0).text_count
puts key
desc = db.find_value(key)
puts desc

key = Transformer::Key.create(1, 1, 1).root("catalog").elem!("book", 1).elem!("description", 0).text(0)
puts key
desc = db.find_value(key)
puts desc

key = Transformer::Key.create(1, 1, 1).root("catalog").elem!("book", 1).elem!("description", 0).text(1)
puts key
desc = db.find_value(key)
puts desc

key = Transformer::Key.create(1, 1, 1).root("catalog").elem!("book", 1).elem!("description", 0).count
puts key
desc = db.find_value(key)
puts desc

key = Transformer::Key.create(1, 1, 1).root("catalog").elem!("book", 1).elem!("genre", 0).count
puts key
desc = db.find_value(key)
puts desc

puts "    s     s   s\n".strip
puts "   \n".sub('\n', '').strip.empty?
puts "konec"


# puts Transformer::KeyElementBuilder.build_from_s("1::1::1::catalog")
# puts Transformer::KeyElementBuilder.build_from_s("1::1::1::catalog::elem1>1")
# puts Transformer::KeyElementBuilder.build_from_s("1::1::1::catalog::elem1>1>text>1")
# puts Transformer::KeyElementBuilder.build_from_s("1::1::1::catalog::elem1>1::elem2")
# puts Transformer::KeyElementBuilder.text?("1::1::1::catalog::elem1>1::elem2")
# puts Transformer::KeyElementBuilder.text?("1::1::1::catalog::elem1>1::elem2>text>1")
# puts Transformer::KeyElementBuilder.text_order("1::1::1::catalog::elem1>1::elem2>text>1")
# puts Transformer::KeyElementBuilder.build_from_s("1::1::1::catalog::elem1>1").elem_name
# puts Transformer::KeyElementBuilder.build_from_s("1::1::1::catalog::elem1>1>text>1").order

# puts hash["name"]
# puts hash["version"]

