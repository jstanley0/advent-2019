require_relative 'computer'

game = Computer.new
screen = []

def wall_char(tile_id)
  case tile_id
  when 0; ' '
  when 1; '#'
  when 2; 'x'
  when 3; '-'
  when 4; 'o'
  end
end

def plot_tile(screen, x, y, tile_id)
  screen[y] ||= []
  screen[y][x] = wall_char(tile_id)
end
ball = -1
paddle = -1
score = 0

game.poke 0, 2

loop do
  x = game.compute
  break unless x
  if x == :need_input
    joystick = if paddle < ball
      1
    elsif paddle > ball
      -1
    else
      0
    end
    game.queue_input(joystick)
    next
  end
  y = game.compute
  tile_id = game.compute
  if x < 0
    score = tile_id
  else
    ball = x if tile_id == 4
    paddle = x if tile_id == 3
    plot_tile(screen, x, y, tile_id)
  end

  display = screen.map(&:join).join("\n")
  puts display
  puts score
end



