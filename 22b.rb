CARDS = 119315717514047
SHUFFLES = 101741582076661

# lol I don't even know how to think about this

card = 2020

ARGF.each_line do |line|
  if line =~ /deal into new stack/

  elsif line =~ /cut (-?\d+)/

  elsif line =~ /deal with increment (\d+)/

  end
end

