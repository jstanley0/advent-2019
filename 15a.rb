require 'byebug'
require_relative 'computer'

$map = 50.times.map { " " * 50 }
$x = 25
$y = 25
$map[$y][$x] = 'D'

CONJUGATE = [nil, 2, 1, 4, 3]
DX = [nil, 0, 0, -1, 1]
DY = [nil, -1, 1, 0, 0]

def plot_wall(move)
  $map[$y + DY[move]][$x + DX[move]] = '#'
end

def plot_move(move)
  $map[$y][$x] = '.' if $map[$y][$x] == 'D'
  $x += DX[move]
  $y += DY[move]
  $map[$y][$x] = 'D'
end

def draw_map
  system('clear')
  puts $map.join("\n")
end

path = []
move = 1
goal = nil
robot = Computer.new
loop do
  #draw_map
  move += 1 if path.any? && move == CONJUGATE[path.last]
  if move <= 4
    status = robot.compute move
    case status
    when 0
      plot_wall(move)
      # hit a wall; try a different direction...
      move += 1
    when 1, 2
      plot_move(move)
      # moved
      path << move
      # check goal
      if status == 2 && goal.nil?
        goal = { x: $x, y: $y, length: path.length }
        $map[$y][$x] = 'O'
      end
      move = 1
    end
  else
    # backtrack
    break if path.empty?
    last_move = path.pop
    undo_move = CONJUGATE[last_move]
    status = robot.compute undo_move
    raise "reality fault" unless status == 1
    plot_move(undo_move)
    move = last_move + 1
  end
end

draw_map

raise "oxygen not found" unless goal
puts "goal: #{goal.inspect}"

def spread_oxygen_to(x, y)
  if $map[y][x] == '.'
    $map[y][x] = 'O'
    return [x, y]
  end
  nil
end

def spread_oxygen_from(x, y)
  frontier = []
  frontier << spread_oxygen_to(x - 1, y)
  frontier << spread_oxygen_to(x, y - 1)
  frontier << spread_oxygen_to(x + 1, y)
  frontier << spread_oxygen_to(x, y + 1)
  frontier.compact
end

time = 0
leading_edge = [[goal[:x], goal[:y]]]
loop do
  next_edge = []
  leading_edge.each do |x, y|
    next_edge.concat spread_oxygen_from(x, y)
  end
  break if next_edge.empty?
  leading_edge = next_edge
  time += 1
  draw_map
  puts time
end
