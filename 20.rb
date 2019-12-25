require 'byebug'
require 'set'

def letter?(char)
  ('A'..'Z').include?(char)
end

def traverse_portal(label, from_x = nil, from_y = nil)
  $maze.each_with_index do |row, y|
    for x in 0...row.size
      next if from_x == x && from_y == y
      if $maze[y][x] == label[0]
        if x < row.size - 1 && $maze[y][x + 1] == label[1]
          next if from_x == x + 1 && from_y == y
          $traversed_portals << label
          return x - 1, y if x > 0 && row[x - 1] == '.'
          return x + 2, y if x < row.size - 2 && row[x + 2] == '.'
          raise "couldn't find path adjacent to horizontal portal #{label}"
        elsif y < $maze.size - 1 && $maze[y + 1][x] == label[1]
          next if from_x == x  && from_y == y + 1
          $traversed_portals << label
          return x, y - 1 if y > 0 && $maze[y - 1][x] == '.'
          return x, y + 2 if y < $maze.size - 2 && $maze[y + 2][x] == '.'
          raise "couldn't find path adjacent to vertical portal #{label}"
        end
      end
    end
  end
  raise "failed to find portal #{label}"
end

def identify_portal(x, y)
  p0 = $maze[y][x]
  raise "not a portal" unless letter?(p0)
  l = $maze[y][x - 1] if x > 0
  return l + p0 if letter?(l)
  u = $maze[y - 1][x] if y > 0
  return u + p0 if letter?(u)
  r = $maze[y][x + 1] if x < $maze[y].size - 1
  return p0 + r if letter?(r)
  d = $maze[y + 1][x] if y < $maze.size - 1
  return p0 + d if letter?(d)
  raise "reality fault"
end

def visit_cell(x, y)
  if $maze[y][x] == '.'
    $maze[y][x] = ' '
    return x, y
  elsif letter?($maze[y][x])
    label = identify_portal(x, y)
    return nil if $traversed_portals.include?(label)
    return :win if label == 'ZZ'
    nx, ny = traverse_portal(label, x, y)
    $maze[ny][nx] = ' '
    return nx, ny
  end
  nil
end

def search_from(x, y)
  frontier = []
  frontier << visit_cell(x - 1, y)
  frontier << visit_cell(x, y - 1)
  frontier << visit_cell(x + 1, y)
  frontier << visit_cell(x, y + 1)
  frontier.compact
end

def draw_maze
  puts $maze.join
end

$maze = ARGF.readlines
$traversed_portals = Set.new
draw_maze
startx, starty = traverse_portal('AA')

time = 0
leading_edge = [[startx, starty]]
loop do
  next_edge = []
  leading_edge.each do |x, y|
    next_edge.concat search_from(x, y)
  end
  break if next_edge.empty?
  break if next_edge.include?(:win)
  leading_edge = next_edge
  time += 1
  draw_maze
  puts time
end

draw_maze
puts time