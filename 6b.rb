$parents = {}
STDIN.each_line do |line|
  parent, child = line.strip.split(')')
  $parents[child] = parent
end

def orbit_chain(obj)
  chain = []
  loop do
    parent = $parents[obj]
    break unless parent
    chain << parent
    obj = parent
  end
  chain
end

you_chain = orbit_chain('YOU')
san_chain = orbit_chain('SAN')

you_chain.each_with_index do |planet, index|
  san_index = san_chain.index(planet)
  next unless san_index
  puts index + san_index
  break
end
