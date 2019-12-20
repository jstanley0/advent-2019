$map = ARGF.readlines.map(&:strip).reject(&:empty?)
w = $map[0].size
h = $map.size
raise "irregular map" unless $map.all? { |row| row.size == w }
STDERR.puts "map size #{w}x#{h}"

Coord = Struct.new(:row, :col)
Asteroid = Struct.new(:angle, :coord)

locations = []
$map.each_with_index do |line, row|
  line.chars.each_with_index do |char, col|
    locations << Coord.new(row, col) if char == '#'
  end
end

def can_see?(from, to)
  rise = to.row - from.row
  run  = to.col - from.col
  denom = rise.gcd(run)
  rise /= denom
  run /= denom

  coord = Coord.new(from.row + rise, from.col + run)
  while coord != to
    return false if $map[coord.row][coord.col] == '#'
    coord.row += rise
    coord.col += run
  end

  true
end

def visibilities_from(locations, from)
  coords = []
  locations.each do |coord|
    next if coord == from
    coords << coord if can_see?(coord, from)
  end
  coords
end

def vaporize_asteroid!(a, locations)
  #STDERR.puts "vaporizing asteroid at angle #{a.angle}"
  $map[a.coord.row][a.coord.col] = '!'
  locations.delete(a.coord)
  #STDERR.puts $map.join("\n")
  #STDERR.puts "---"
end

visibilities = []
locations.each_with_index do |coord, i|
  coords = visibilities_from(locations, locations[i])
  visibilities << [coords.size, coord]
end

station = visibilities.max_by { |v| v[0] }[1]
puts "monitoring station placed at #{station}"
$map[station.row][station.col] = 'X'

kills = 0
sweep = 0
while locations.size > 1
  STDERR.puts "*** sweep #{sweep += 1} ***"
  doomed_asteroids = visibilities_from(locations, station).map do |asteroid|
    angle = Math.atan2(station.col - asteroid.col, asteroid.row - station.row)
    angle -= 2 * Math::PI if angle >= Math::PI
    Asteroid.new(angle, asteroid)
  end.sort_by(&:angle)

  doomed_asteroids.each do |a|
    vaporize_asteroid!(a, locations)
    kills += 1
    if kills == 200
      puts "the 200th asteroid was at #{a.coord}"
      exit 0
    end
  end
end

puts "there were not 200 asteroids to destroy :("
exit 1