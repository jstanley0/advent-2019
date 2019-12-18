require_relative 'computer'

program = ARGF.read
max_power = -1
max_phases = []

(5..9).to_a.permutation.each do |phases|
  computers = phases.map { |phase| Computer.new(program, [phase]) }

  input = 0
  last_output = nil

  loop do
    computers.each { |computer| input = computer.compute(input) }
    break if input.nil?
    last_output = input
  end

  if last_output > max_power
    max_power = last_output
    max_phases = phases
  end
end

puts "#{max_phases.inspect} => #{max_power}"
