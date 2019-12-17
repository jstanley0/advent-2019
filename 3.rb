require 'set'

def plot_wire(wire)
  x = 0
  y = 0

  wire.split(',').each do |seg|
    dir = seg[0]
    dist = seg[1..-1].to_i

    dx, dy = case dir
    when 'U'
      [0, -1]
    when 'D'
      [0, 1]
    when 'L'
      [-1, 0]
    when 'R'
      [1, 0]
    end

    dist.times do
      x += dx
      y += dy
      yield x, y
    end
  end
end

coords = Set.new
plot_wire(readline) do |x, y|
  coords << [x, y]
end

intersections = []
plot_wire(readline) do |x, y|
  if coords.include?([x, y])
    intersections << x.abs + y.abs
  end
end

puts intersections.min


