require_relative 'computer'

program = ARGF.read.freeze
count = 0
for y in 0...50
  for x in 0...50
    r = Computer.new(program).compute(x, y)
    count += r
    print (r == 1) ? '#' : '.'
  end
  puts y
end

puts count