
class Trida
  
  attr_accessor :jmeno, :prijmeni
  
  def initialize(jmeno, prijmeni)
    @jmeno = jmeno
    @prijmeni = prijmeni
  end
  
  def do_it1
    puts "neco"
  end
  
  def do_it2
    puts "neco"
  end
  
  def do_it3
    puts "neco"
  end
  
  def do_it4(helou)
    puts "neco"
  end
  
end

class SubClass < Trida
  
  def do_it5
    puts "neco"
  end
  
end

def time
  start = Time.now
  yield
  time = Time.now - start
  puts "Execution time: #{time} s"
end


key = "neco"

puts "respond"
time do
  1000000.times {
    if(key.respond_to?(:each))
      
    end
  }
end

puts "kind of"
time do
  1000000.times {
    if(key.kind_of?(Array))
      
    end
  }
end

exit
trida = SubClass.new("Mila", "Mnaga")

puts "responod_to?"
time do
  1000000.times {
    if(trida.respond_to?(:jmeno))
      
    end
  }
end

puts "instance_of?"
time do
  1000000.times {
    if(trida.respond_to?(:jmeno, true))
      
    end
  }
end

puts "is_a?"
time do
  1000000.times {
    if(trida.is_a?(SubClass))
      
    end
  }
end

puts "kind_of?"
time do
  1000000.times {
    if(trida.kind_of?(SubClass))
      
    end
  }
end

puts "==="
time do
  1000000.times {
    if(trida === Trida)
      
    end
  }
end








