require 'io/console'
require_relative 'computer'

$map = 40.times.map { " " * 80 }
$x = 40
$y = 20
$map[$y][$x] = 'D'

def target(dir)
  case dir
  when 1; [$x, $y - 1]
  when 2; [$x, $y + 1]
  when 3; [$x - 1, $y]
  when 4; [$x + 1, $y]
  end
end

robot = Computer.new
loop do
  system('clear')
  puts $map.join("\n")
  dir = STDIN.getch.tr('wasdq', '13245').to_i
  break if dir == 5
  next if dir == 0
  dx, dy = target dir
  status = robot.compute dir
  case status
  when 0
    $map[dy][dx] = '#'
  when 1
    $map[dy][dx] = 'D'
    $map[$y][$x] = '.'
    $x, $y = dx, dy
  when 2
    $map[dy][dx] = 'o'
    $map[$y][$x] = '.'
    $x, $y = dx, dy
  end
end