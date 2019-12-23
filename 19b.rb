require_relative 'computer'

# lower slope: 150/109
# upper slope: 151/91
$program = ARGF.read.split(',').map(&:to_i)

# returns [x, w]
def read_row(y, x0)
  x = nil
  xi = x0
  loop do
    # yuno accept multiple coordinates per run
    px = Computer.new($program).compute(xi, y)
    if px == 1
      x = xi if x.nil?
    elsif x
      return [x, xi - x]
    else
      return [0, 1] if xi - x0 > 5 # stupid discontinuous section near the start
    end
    xi += 1
  end
end

x = 0
lastpix = []
for y in 0..999 do
  x, w = read_row(y, x)
  lastpix << x + w - 1
  puts "#{y}: #{w} #{x} #{lastpix[y]}"
  if y >= 200 && w >= 100 && lastpix[y - 99] >= x + 99
    puts "#{x},#{y-99}"
    exit
  end
end

