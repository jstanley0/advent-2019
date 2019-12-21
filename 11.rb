require_relative 'computer'

Coord = Struct.new(:x, :y)

class Robot
  def initialize
    @brain = Computer.new
    @coord = Coord.new(0, 0)
    @angle = 0
    @painted_squares = {}
    @painted_squares[@coord] = 1
  end

  def run
    loop do
      result = @brain.compute
      break if result.nil?
      if result == :need_input
        @brain.queue_input(white_square?(@coord) ? 1 : 0)
        next
      end
      paint_square!(@coord, result)
      turn = @brain.compute
      turn!((turn == 1) ? -90 : 90)
      move!
    end
  end

  def painted_square_count
    @painted_squares.size
  end

  def print_picture
    xv = @painted_squares.keys.map(&:x)
    yv = @painted_squares.keys.map(&:y)
    (yv.min..yv.max).each do |y|
      (xv.min..xv.max).each do |x|
        print white_square?(Coord.new(x, y)) ? '*' : ' '
      end
      puts
    end
  end

  private

  def turn!(angle)
    @angle = (@angle + angle) % 360
  end

  def move!
    case @angle
    when 0
      @coord.y -= 1
    when 90
      @coord.x -= 1
    when 180
      @coord.y += 1
    when 270
      @coord.x += 1
    end
  end

  def paint_square!(coord, color)
    @painted_squares[coord.dup] = color
  end

  def white_square?(coord)
    @painted_squares[coord] == 1
  end

end

robot = Robot.new
robot.run
puts robot.painted_square_count
robot.print_picture