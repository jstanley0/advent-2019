$map = ARGF.readlines.map(&:strip).reject(&:empty?)
w = $map[0].size
h = $map.size
raise "irregular map" unless $map.all? { |row| row.size == w }
STDERR.puts "map size #{w}x#{h}"

Coord = Struct.new(:row, :col)

locations = []
$map.each_with_index do |line, row|
  line.chars.each_with_index do |char, col|
    locations << Coord.new(row, col) if char == '#'
  end
end

def can_see?(locations, from, to)
  rise = locations[to].row - locations[from].row
  run  = locations[to].col - locations[from].col
  denom = rise.gcd(run)
  rise /= denom
  run /= denom

  coord = Coord.new(locations[from].row + rise, locations[from].col + run)
  while coord != locations[to]
    return false if $map[coord.row][coord.col] == '#'
    coord.row += rise
    coord.col += run
  end

  true
end

def count_visibilities_from(locations, i)
  n = 0
  locations.each_with_index do |coords, j|
    next if i == j
    n += 1 if can_see?(locations, i, j)
  end
  n
end

visibilities = []
locations.each_with_index do |coords, i|
  n = count_visibilities_from(locations, i)
  visibilities << [n, coords]
end

puts visibilities.max_by { |v| v[0] }.inspect