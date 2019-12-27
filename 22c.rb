CARDS = 119315717514047
SHUFFLES = 101741582076661
POS = 2020

ops = []
a = 1
b = 0

ARGF.each_line do |line|
  if line =~ /deal into new stack/
    a = -a % CARDS
    b = (CARDS - 1 - b) % CARDS
  elsif line =~ /cut (-?\d+)/
    b = (b - $1.to_i) % CARDS
  elsif line =~ /deal with increment (\d+)/
    a = (a * $1.to_i) % CARDS
    b = (b * $1.to_i) % CARDS
  end
end

puts "a = #{a}; b = #{b}"

# okay I'll be honest here: I do not understand this math at all :(
r = (b * (1 - a).pow(CARDS - 2, CARDS)) % CARDS
puts ((POS - r) * a.pow(SHUFFLES * (CARDS - 2), CARDS) + r) % CARDS