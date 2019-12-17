$moon_map = {}
STDIN.each_line do |line|
  parent, child = line.strip.split(')')
  $moon_map[parent] ||= []
  $moon_map[parent] << child
end

def count_orbits(thing, indirect_count)
  ret = 0
  moons = $moon_map[thing]
  if moons
    moons.each do |moon|
      ret += count_orbits(moon, indirect_count + 1)
    end
  end
  ret + indirect_count
end

puts count_orbits('COM', 0)

