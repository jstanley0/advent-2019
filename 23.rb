require_relative 'computer'

program = ARGF.read.freeze

nics = (0..49).each.map do |addr|
  Computer.new(program, [addr])
end

packets = {}
natx = nil
naty = nil
lastnaty = nil
loop do
  idle = packets.empty?
  nics.each_with_index do |nic, addr|
    nic.queue_input(*packets.delete(addr)) if packets[addr]
    res = nic.compute
    if res == :need_input
      nic.queue_input(-1)
    else
      idle = false
      dest = res
      x = nic.compute
      y = nic.compute
      if dest == 255
        natx = x
        naty = y
      end
      if dest < 50
        packets[dest] ||= []
        packets[dest].concat([x, y])
      end
    end
  end
  if idle
    if !naty.nil? && naty == lastnaty
      puts "teh answer is #{naty}"
      exit
    end
    packets[0] ||= []
    packets[0].concat([natx, naty])
    lastnaty = naty
  end
end
