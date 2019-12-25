require 'byebug'
require 'set'

def letter?(char)
  ('A'..'Z').include?(char)
end

def prep_floor(z)
  if z > $maze.size
    raise "skipping floors is not allowed"
  elsif z == $maze.size
    $maze << $master.map(&:dup)
    STDERR.puts "loaded floor #{z}"
  end
end

def find_dest_floor(from_x, from_y, from_z)
  return from_z if from_x.nil? # initial port in
  # outer portals go down a floor; inner portals go up a floor
  new_z = if from_x <= 4 || from_y <= 4 || from_x >= $master[0].size - 4 || from_y >= $master.size - 4
    from_z - 1
  else
    from_z + 1
  end
  prep_floor(new_z) if new_z >= 0
  new_z
end

def traverse_portal(label, from_x, from_y, from_z)
  new_z = find_dest_floor(from_x, from_y, from_z)
  return nil if new_z < 0
  $maze[new_z].each_with_index do |row, y|
    for x in 0...row.size
      next if from_x == x && from_y == y
      if $maze[new_z][y][x] == label[0]
        if x < row.size - 1 && row[x + 1] == label[1]
          next if from_x == x + 1 && from_y == y
          row[x] = row[x].downcase # prevent re-entering the portal
          row[x + 1] = row[x + 1].downcase
          STDERR.puts "exited portal #{label} on floor #{new_z}"
          return x - 1, y, new_z if x > 0 && row[x - 1] == '.'
          return x + 2, y, new_z if x < row.size - 2 && row[x + 2] == '.'
          STDERR.puts "blocked portal exit for #{label} on floor #{new_z}"
          return nil
        elsif y < $maze[new_z].size - 1 && $maze[new_z][y + 1][x] == label[1]
          next if from_x == x && from_y == y + 1
          $maze[new_z][y][x] = $maze[new_z][y][x].downcase # prevent re-entering the portal
          $maze[new_z][y + 1][x] = $maze[new_z][y + 1][x].downcase
          STDERR.puts "exited portal #{label} on floor #{new_z}"
          return x, y - 1, new_z if y > 0 && $maze[new_z][y - 1][x] == '.'
          return x, y + 2, new_z if y < $maze[new_z].size - 2 && $maze[new_z][y + 2][x] == '.'
          STDERR.puts "blocked portal exit for #{label} on floor #{new_z}"
          return nil
        end
      end
    end
  end
  raise "failed to find portal #{label}"
end

def identify_portal(x, y, z)
  p0 = $maze[z][y][x]
  raise "not a portal" unless letter?(p0)
  l = $maze[z][y][x - 1] if x > 0
  return l + p0 if letter?(l)
  u = $maze[z][y - 1][x] if y > 0
  return u + p0 if letter?(u)
  r = $maze[z][y][x + 1] if x < $maze[z][y].size - 1
  return p0 + r if letter?(r)
  d = $maze[z][y + 1][x] if y < $maze[z].size - 1
  return p0 + d if letter?(d)
  raise "reality fault"
end

def visit_cell(x, y, z)
  if $maze[z][y][x] == '.'
    $maze[z][y][x] = ' '
    return x, y, z
  elsif letter?($maze[z][y][x])
    label = identify_portal(x, y, z)
    return nil if label == 'AA'
    return (z == 0 ? :win : nil) if label == 'ZZ'
    nx, ny, nz = traverse_portal(label, x, y, z)
    return nil if nx.nil? # closed portal
    $maze[nz][ny][nx] = ' '
    return nx, ny, nz
  end
  nil
end

def search_from(x, y, z)
  frontier = []
  frontier << visit_cell(x - 1, y, z)
  frontier << visit_cell(x, y - 1, z)
  frontier << visit_cell(x + 1, y, z)
  frontier << visit_cell(x, y + 1, z)
  frontier.compact
end

$master = ARGF.readlines.map(&:freeze).freeze
$maze = []
prep_floor(0)

startx, starty = traverse_portal('AA', nil, nil, 0)

$trace = nil
$time = 0
leading_edge = [[startx, starty, 0]]
loop do
  puts $maze[$trace].join if $trace
  puts $time if $trace
  sleep 1 if $trace
  next_edge = []
  leading_edge.each do |x, y, z|
    next_edge.concat search_from(x, y, z)
  end
  break if next_edge.empty?
  break if next_edge.include?(:win)
  leading_edge = next_edge
  $time += 1
end

puts $time