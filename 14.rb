CARGO = 1000000000000

class Quantity
  attr_accessor :chem, :amount

  def initialize(text)
    m = text.match(/(\d+) (\w+)/)
    @amount = m[1].to_i
    @chem = m[2]
  end

  def *(quantity)
    ret = self.dup
    ret.amount *= quantity
    ret
  end

  def to_s
    "#{@amount} #{@chem}"
  end
end

class Reaction
  attr_accessor :reagents, :product

  def initialize(text)
    @text = text
    reagents, product = text.split('=>')
    @reagents = reagents.split(',').map { |r| Quantity.new(r) }
    @product = Quantity.new(product)
  end

  def to_s
    @text
  end
end

def leftover(chem, amount)
  return if amount == 0
  $leftovers[chem] ||= 0
  $leftovers[chem] += amount
  #puts "new quantity of leftover #{chem} is #{$leftovers[chem]}"
end

def consume_leftover(chem, amount)
  to_consume = [$leftovers[chem] || 0, amount].min
  return amount if to_consume == 0
  leftover(chem, -to_consume)
  amount - to_consume
end

def ore_cost(product)
  #puts "cost of #{product}..."
  if product.chem == 'ORE'
    #puts "#{product.amount}"
    return product.amount
  end
  amount = consume_leftover(product.chem, product.amount)
  reaction = $reactions.find { |r| r.product.chem == product.chem }
  m = (amount.to_f / reaction.product.amount).ceil
  leftover(product.chem, reaction.product.amount * m - amount)
  reaction.reagents.map { |reagent| ore_cost(reagent * m) }.inject(:+)
end

def fuel_cost(amount)
  $leftovers = {}
  q = Quantity.new("#{amount} FUEL")
  cost = ore_cost(q)
  puts "cost for #{q}: #{cost}"
  cost
end

def fuel_search(min, max)
  return if max - min < 2
  mean = (min + max) / 2
  cmid = fuel_cost(mean)
  if cmid > CARGO
    fuel_search(min, mean)
  else
    fuel_search(mean, max)
  end
end

$reactions = ARGF.readlines.select { |line| line.include?('=>') }.map { |line| Reaction.new(line) }.freeze

cost1 = fuel_cost(1)
min_fuel = CARGO / cost1
max_fuel = min_fuel * 2
fuel_search(min_fuel, max_fuel)
