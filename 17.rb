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

program = ARGF.read.freeze
computer = Computer.new(program)

map = ''
loop do
  c = computer.compute
  break if c.nil?
  map += c.chr
end
puts map

map = map.split("\n")

puts find_intersections(map).map { |coords| coords.inject(:*) }.inject(:+)

computer = Computer.new(program)
computer.poke 0, 2
computer.ascii_input(<<STUPID_ROOMBA)
A,B,A,C,A,B,A,C,B,C
R,4,L,12,L,8,R,4
L,8,R,10,R,10,R,6
R,4,R,10,L,12
n
STUPID_ROOMBA
loop do
  r = computer.compute
  if r < 127
    print r.chr
  else
    puts r
    break
  end
end
