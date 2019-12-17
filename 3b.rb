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

cost = 0
costs = {}
plot_wire(readline) do |x, y|
  cost += 1
  costs[[x, y]] ||= cost
end

intersections = []
cost = 0
plot_wire(readline) do |x, y|
  cost += 1
  other_cost = costs[[x, y]]
  if other_cost
    intersections << cost + other_cost
  end
end

puts intersections.min


