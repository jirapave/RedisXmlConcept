require_relative "../db_init"
require_relative "../../lib/transformer/key_builder"
require_relative "../../lib/transformer/key_element_builder"
require "test/unit"

class TestKeyElementBuilder < Test::Unit::TestCase
  
  def setup()
    @key_builder = Transformer::KeyBuilder.new("1", "2", "3")
    @key_elem_builder = Transformer::KeyElementBuilder.new(@key_builder, "1")
  end
  
  def test_elem!()
    puts "NILL to neni mozne" unless @key_elem_builder
    assert_equal(true, @key_elem_builder.elem!("30", "2").key_str == "1:30>2")
    assert_equal(true, @key_elem_builder.elem!(2, 3).key_str == "1:30>2:2>3")
    assert_equal(true, @key_elem_builder.elem!(71, "4").elem!("2", 1).key_str == "1:30>2:2>3:71>4:2>1")
  end
  
  def test_elem()
    assert_equal(true, @key_elem_builder.elem("30", "2") == "1:30>2")
    assert_equal(true, @key_elem_builder.elem(2, 3) == "1:2>3")
    assert_equal(true, @key_elem_builder.elem(71, "4") == "1:71>4")
    assert_equal(true, @key_elem_builder.elem!(71, "4").elem("341", 1003) == "1:71>4:341>1003")
  end
  
  def test_attr()
    puts "key_elem build je: #{@key_elem_builder}"
    assert_equal(true, @key_elem_builder.attr() == "1<a")
    assert_equal(true, @key_elem_builder.elem!(123, 2).attr() == "1:123>2<a")
  end
  
  def test_text()
    assert_equal(true, @key_elem_builder.text(3) == "1>t>3")
    assert_equal(true, @key_elem_builder.elem!(981, 312).text("1001") == "1:981>312>t>1001")
  end
  
  def test_comment()
    assert_equal(true, @key_elem_builder.comment(5) == "1>c>5")
    assert_equal(true, @key_elem_builder.elem!(122, 91).comment("1000") == "1:122>91>c>1000")
  end
    
  def test_cdata()
    assert_equal(true, @key_elem_builder.cdata(99) == "1>d>99")
    assert_equal(true, @key_elem_builder.elem!(2, 272).cdata("99") == "1:2>272>d>99")
  end
  
  def test_parent!()
    assert_raise Transformer::NoElementError do
     @key_elem_builder.parent!
    end
    @key_elem_builder.elem!(12, 2).elem!("125", 54)
    assert_equal(true, @key_elem_builder.parent!.key_str == "1:12>2")
    @key_elem_builder.elem!(95, 45).elem!("12", "111")
    assert_equal(true, @key_elem_builder.parent!.key_str == "1:12>2:95>45")
    assert_equal(true, @key_elem_builder.parent!.parent!.key_str == "1")
  end
  
  def test_parent()
    assert_raise Transformer::NoElementError do
     @key_elem_builder.parent
    end
    @key_elem_builder.elem!(11, "3").elem!(87, 32)
    assert_equal(true, @key_elem_builder.parent == "1:11>3")
    @key_elem_builder.elem!(54, 33).elem!("34", 112)
    assert_equal(true, @key_elem_builder.parent == "1:11>3:87>32:54>33")
    assert_equal(true, @key_elem_builder.parent!.parent == "1:11>3:87>32")
    assert_equal(true, @key_elem_builder.parent!.parent!.parent == "1")
  end
  
  def test_next_elem!()
    assert_raise Transformer::NoElementError do
     @key_elem_builder.next_elem!
    end
    @key_elem_builder.elem!(41, "2").elem!(1, 1)
    assert_equal(true, @key_elem_builder.next_elem!.key_str == "1:41>2:1>2")
    assert_equal(true, @key_elem_builder.next_elem!.key_str == "1:41>2:1>3")
    @key_elem_builder.elem!(3, "99")
    assert_equal(true, @key_elem_builder.next_elem!.key_str == "1:41>2:1>3:3>100")
  end
  
  def test_next_elem()
    assert_raise Transformer::NoElementError do
     @key_elem_builder.next_elem
    end
    @key_elem_builder.elem!(41, "2").elem!(1, 1)
    assert_equal(true, @key_elem_builder.next_elem == "1:41>2:1>2")
    @key_elem_builder.elem!(3, "1999")
    assert_equal(true, @key_elem_builder.next_elem == "1:41>2:1>1:3>2000")
  end
  
  def test_prev_elem!()
    assert_raise Transformer::NoElementError do
     @key_elem_builder.prev_elem!
    end
    @key_elem_builder.elem!(23, "2").elem!(1, 30)
    assert_equal(true, @key_elem_builder.prev_elem!.key_str == "1:23>2:1>29")
    assert_equal(true, @key_elem_builder.prev_elem!.key_str == "1:23>2:1>28")
    @key_elem_builder.elem!(3, "100")
    assert_equal(true, @key_elem_builder.prev_elem!.key_str == "1:23>2:1>28:3>99")
    @key_elem_builder.elem!(999, "1")
    assert_raise Transformer::WrongOrderError do
     @key_elem_builder.prev_elem!
    end
  end
  
  def test_prev_elem()
    assert_raise Transformer::NoElementError do
     @key_elem_builder.prev_elem
    end
    @key_elem_builder.elem!(23, "2").elem!(1, 30)
    assert_equal(true, @key_elem_builder.prev_elem == "1:23>2:1>29")
    @key_elem_builder.elem!(3, "100")
    assert_equal(true, @key_elem_builder.prev_elem == "1:23>2:1>30:3>99")
    @key_elem_builder.elem!(999, "1")
    assert_raise Transformer::WrongOrderError do
     @key_elem_builder.prev_elem
    end
  end
  
  def test_root_only?()
    assert_equal(true, @key_elem_builder.root_only? == true)
    @key_elem_builder.elem!(1,1)
    assert_equal(true, @key_elem_builder.root_only? == false)
    assert_equal(true, @key_elem_builder.parent!.root_only? == true)
  end
  
  def test_elem_id()
    assert_equal(true, @key_elem_builder.elem_id == "1")
    @key_elem_builder.elem!(12,29)
    assert_equal(true, @key_elem_builder.elem_id == "12")
    @key_elem_builder.elem!(99,99)
    assert_equal(true, @key_elem_builder.elem_id == "99")
    @key_elem_builder.parent!
    assert_equal(true, @key_elem_builder.elem_id == "12")
    @key_elem_builder.parent!
    assert_equal(true, @key_elem_builder.elem_id == "1")
  end
  
  def test_order()
    assert_raise Transformer::WrongOrderError do
     @key_elem_builder.order
    end
    @key_elem_builder.elem!(2,99)
    assert_equal(true, @key_elem_builder.order == 99)
    @key_elem_builder.next_elem!
    assert_equal(true, @key_elem_builder.order == 100)
    @key_elem_builder.elem!(2, 12)
    assert_equal(true, @key_elem_builder.order == 12)
    @key_elem_builder.parent!
    assert_equal(true, @key_elem_builder.order == 100)
    @key_elem_builder.prev_elem!
    assert_equal(true, @key_elem_builder.order == 99)
    @key_elem_builder.parent!
    assert_raise Transformer::WrongOrderError do
     @key_elem_builder.order
    end
  end
  
  def test_text_order()
    assert_raise Transformer::WrongOrderError do
     Transformer::KeyElementBuilder.text_order("1")
    end
    assert_raise Transformer::WrongOrderError do
     Transformer::KeyElementBuilder.text_order("1:2>2:99>1000")
    end
    assert_equal(true, Transformer::KeyElementBuilder.text_order("1:2>99>t>3") == 3)
    assert_equal(true, Transformer::KeyElementBuilder.text_order("1:2>99:987>21>t>99") == 99)
  end
  
  def test_text?()
    assert_equal(true, Transformer::KeyElementBuilder.text?("1") == false)
    assert_equal(true, Transformer::KeyElementBuilder.text?("1:2>1") == false)
    assert_equal(true, Transformer::KeyElementBuilder.text?("1:56>4>t>4:99>100") == false)
    assert_equal(true, Transformer::KeyElementBuilder.text?("1:3>4>t>99") == true)
    assert_equal(true, Transformer::KeyElementBuilder.text?("1:3>65>t>11:4>5>t>2") == true)
  end
  
  def test_comment?()
    assert_equal(true, Transformer::KeyElementBuilder.comment?("1") == false)
    assert_equal(true, Transformer::KeyElementBuilder.comment?("1:2>1") == false)
    assert_equal(true, Transformer::KeyElementBuilder.comment?("1:56>4>c>4:99>100") == false)
    assert_equal(true, Transformer::KeyElementBuilder.comment?("1:3>4>c>99") == true)
    assert_equal(true, Transformer::KeyElementBuilder.comment?("1:3>65>c>11:4>5>c>2") == true)
  end
  
  def test_cdata?()
    assert_equal(true, Transformer::KeyElementBuilder.cdata?("1") == false)
    assert_equal(true, Transformer::KeyElementBuilder.cdata?("1:2>1") == false)
    assert_equal(true, Transformer::KeyElementBuilder.cdata?("1:56>4>d>4:99>100") == false)
    assert_equal(true, Transformer::KeyElementBuilder.cdata?("1:3>4>d>99") == true)
    assert_equal(true, Transformer::KeyElementBuilder.cdata?("1:3>65>t>11:4>5>d>2") == true)
  end
  
  def test_element?()
    assert_equal(true, Transformer::KeyElementBuilder.element?("1") == true)
    assert_equal(true, Transformer::KeyElementBuilder.element?("1:2>1") == true)
    assert_equal(true, Transformer::KeyElementBuilder.element?("1:56>4>d>4:99>100") == true)
    assert_equal(true, Transformer::KeyElementBuilder.element?("1:3>4>d>99") == false)
    assert_equal(true, Transformer::KeyElementBuilder.element?("1:3>65>t>11:4>5>d>2") == false)
    assert_equal(true, Transformer::KeyElementBuilder.element?("1:3>65>t>99:4>12>t>2") == false)
  end
  
  def test_build_from_s()
    test_one = "1:2>7:5>1"
    test_two = "2:7>2:3>99>t>2"
    @key_elem_builder = Transformer::KeyElementBuilder.build_from_s(@key_builder, test_one)
    assert_equal(true, @key_elem_builder.key_str == test_one)
    assert_equal(true, @key_elem_builder.order == 1)
    @key_elem_builder.next_elem!
    assert_equal(true, @key_elem_builder.order == 2)
    @key_elem_builder.parent!
    assert_equal(true, @key_elem_builder.order == 7)
    
    @key_elem_builder = Transformer::KeyElementBuilder.build_from_s(@key_builder, test_two)
    #Attention here! Text keys are not supported, this is how it's supposed to be
    assert_equal(true, @key_elem_builder.key_str == "2:7>2:3>99")
    assert_equal(true, @key_elem_builder.order == 99)
    @key_elem_builder.next_elem!
    assert_equal(true, @key_elem_builder.order == 100)
    @key_elem_builder.parent!
    assert_equal(true, @key_elem_builder.order == 2)
  end
end
  