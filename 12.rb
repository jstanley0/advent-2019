require 'pp'

=begin
moons = [[[-1, 0, 2], [0, 0, 0]],
         [[2, -10, -7], [0, 0, 0]],
         [[4, -8, 8], [0, 0, 0]],
         [[3, 5, -1], [0, 0, 0]]]
=end

moons = [[[-7, -8, 9], [0, 0, 0]],
         [[-12, -3, -4], [0, 0, 0]],
         [[6, -17, -9], [0, 0, 0]],
         [[4, -10, -6], [0, 0, 0]]]

steps = 0
puts "step 0"
pp moons

loop do
  # apply "gravity"
  moons.each_with_index do |lmoon, i|
    moons[i + 1..-1].each_with_index do |rmoon, j|
      for axis in 0..2
        if lmoon[0][axis] < rmoon[0][axis]
          lmoon[1][axis] += 1
          rmoon[1][axis] -= 1
        elsif lmoon[0][axis] > rmoon[0][axis]
          lmoon[1][axis] -= 1
          rmoon[1][axis] += 1
        end
      end
    end
  end

  # apply velocity
  moons.each do |moon|
    for axis in 0..2
      moon[0][axis] += moon[1][axis]
    end
  end

  steps += 1
  #puts "step #{steps}"
  #pp moons

  break if steps == 1000
end

puts moons.map { |moon|
  moon.map { |e| e.map(&:abs).inject(:+) }.inject(:*)
}.inject(:+)