#CARDS = 10
CARDS = 10007

cards = (0...CARDS).to_a

ARGF.each_line do |line|
  if line =~ /deal into new stack/
    cards.reverse!
  elsif line =~ /cut (-?\d+)/
    i = $1.to_i
    cards = cards[i..-1] + cards[0...i]
  elsif line =~ /deal with increment (\d+)/
    new_cards = []
    i = $1.to_i
    for j in 0...cards.size
      new_cards[(i * j) % cards.size] = cards[j]
    end
    cards = new_cards
  end
end

puts cards.index(2019)