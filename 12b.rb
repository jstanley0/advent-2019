require 'pp'
require 'byebug'

MOONS = [[-7, -8, 9],
         [-12, -3, -4],
         [6, -17, -9],
         [4, -10, -6]]

def find_loop(axis)
  p0 = MOONS.map { |c| c[axis] }
  v0 = MOONS.map { 0 }
  positions = p0.dup
  velocities = v0.dup
  steps = 0
  loop do
    # apply "gravity"
    positions.each_index do |i|
      for j in i + 1...MOONS.size
        if positions[i] < positions[j]
          velocities[i] += 1
          velocities[j] -= 1
        elsif positions[i] > positions[j]
          velocities[i] -= 1
          velocities[j] += 1
        end
      end
    end

    # apply velocity
    positions.each_index do |i|
      positions[i] += velocities[i]
    end

    steps += 1
    puts "axis #{axis} step #{steps}" if steps % 10000 == 0

    return steps if positions == p0 && velocities == v0
  end
end

l = 1
(0..2).each { |i| l = l.lcm(find_loop(i)) }

puts l