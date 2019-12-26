CARDS = 10007

class CardOp
  def tag; end
end

class Reverse < CardOp
  def initialize
  end

  def inspect
    'reverse'
  end

  def perform(deck)
    deck.reverse
  end
end

class Cut < CardOp
  attr_reader :arg

  def initialize(arg)
    @arg = arg
  end

  def inspect
    "cut #{@arg}"
  end

  def perform(deck)
    deck[@arg..-1] + deck[0...@arg]
  end
end

class Splay < CardOp
  attr_reader :arg

  def initialize(arg)
    @arg = arg
  end

  def inspect
    "splay #{@arg}"
  end

  def perform(deck)
    raise "broken" if deck.size % @arg == 0
    new_deck = []
    for j in 0...deck.size
      new_deck[(@arg * j) % deck.size] = deck[j]
    end
    new_deck
  end
end

def bubbleReverse(ops)
  for i in 1...ops.size
    if ops[i].is_a?(Reverse)
      if ops[i - 1].is_a?(Cut)
        arg = ops[i - 1].arg
        ops.delete_at(i - 1)
        ops.insert(i, Cut.new(-arg))
        return true
      elsif ops[i - 1].is_a?(Splay)
        arg = ops[i - 1].arg
        ops.delete_at(i - 1)
        ops.insert(i, Cut.new((1 - arg) % CARDS))
        ops.insert(i, Splay.new(arg))
        return true
      elsif ops[i - 1].is_a?(Reverse)
        ops.delete_at(i - 1)
        ops.delete_at(i - 1)
      end
    end
  end
  false
end

def bubbleSplay(ops)
  for i in 1...ops.size
    if ops[i].is_a?(Splay)
      if ops[i - 1].is_a?(Cut)
        x = ops[i - 1].arg
        y = ops[i].arg
        ops.delete_at(i - 1)
        ops.insert(i, Cut.new((x * y) % CARDS))
        return true
      elsif ops[i - 1].is_a?(Splay)
        x = ops[i - 1].arg
        y = ops[i].arg
        ops.delete_at(i - 1)
        ops.delete_at(i - 1)
        ops.insert(i - 1, Splay.new((x * y) % CARDS))
        return true
      end
    end
  end
  false
end

def consolidateCut(ops)
  for i in 1...ops.size
    if ops[i].is_a?(Cut) && ops[i - 1].is_a?(Cut)
      x = ops[i - 1].arg
      y = ops[i].arg
      ops.delete_at(i - 1)
      ops.delete_at(i - 1)
      ops.insert(i - 1, Cut.new((x + y) % CARDS)) unless x + y == 0
      return true
    end
  end
  false
end

ops = []
ARGF.each_line do |line|
  if line =~ /deal into new stack/
    ops << Reverse.new
  elsif line =~ /cut (-?\d+)/
    ops << Cut.new($1.to_i)
  elsif line =~ /deal with increment (\d+)/
    ops << Splay.new($1.to_i)
  end
end

def sanity_check(ops)
  cards = (0...CARDS).to_a
  ops.each { |op| cards = op.perform(cards) }
  puts cards[0..30].inspect
  puts cards.index(2019)
end

sanity_check ops

while bubbleReverse(ops); end

sanity_check ops

while bubbleSplay(ops); end

sanity_check ops

while consolidateCut(ops); end

sanity_check ops

puts ops.inspect