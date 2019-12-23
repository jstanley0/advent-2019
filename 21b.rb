require_relative 'computer'

# let's try this: (!A || !B || !C) && (E || H) && D

droid = Computer.new
droid.ascii_input <<SPRINGSCRIPT
NOT A J
NOT B T
OR T J
NOT C T
OR T J
NOT E T
NOT T T
OR H T
AND T J
AND D J
RUN
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
