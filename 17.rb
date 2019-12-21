require_relative 'computer'

def find_intersections(map)
  intersections = []
  map.each_with_index do |row, y|
    row.chars.each_with_index do |char, x|
      if char == '#' && [
           row[x - 1] == '#',
           row[x + 1] == '#',
           y > 0 && map[y - 1][x] == '#',
           y < map.size - 1 && map[y + 1][x] == '#'\
          ].select { |x| x == true }.count >= 3
        intersections << [x, y]
      end
    end
  end
  intersections
end

computer = Computer.new

map = ''
loop do
  c = computer.compute
  break if c.nil?
  map += c.chr
end

map = map.split("\n")

puts find_intersections(map).map { |coords| coords.inject(:*) }.inject(:+)