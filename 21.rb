require_relative 'computer'

# let's try this: (!A || !B || !C) && D

droid = Computer.new
droid.ascii_input <<SPRINGSCRIPT
NOT A J
NOT B T
OR T J
NOT C T
OR T J
AND D J
WALK
SPRINGSCRIPT

loop do
  res = droid.compute
  break if res.nil?
  if res < 128
    print res.chr
  else
    puts res
  end
end
