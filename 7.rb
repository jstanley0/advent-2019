ARGCOUNT = [
  0,  # N/A
  3,  # add
  3,  # mul
  1,  # in
  1,  # out
  2,  # jnz
  2,  # jz
  3,  # lt
  3,  # eq
]

def run(memory, inputs = [])
  ip = 0
  outputs = []
  while true
    instcode = memory[ip]
    raise "nil opcode encountered" if instcode.nil?

    opcode = instcode % 100
    arg0imm = (instcode / 100) % 10 == 1
    arg1imm = (instcode / 1000) % 10 == 1

    argcount = ARGCOUNT[opcode] || 0
    args = memory[ip + 1..ip + argcount]
    arg0 = (arg0imm ? args[0] : memory[args[0]]) if argcount >= 1
    arg1 = (arg1imm ? args[1] : memory[args[1]]) if argcount >= 2

    jump_target = nil
    case opcode
    when 1 # add
      memory[args[2]] = arg0 + arg1
    when 2 # mul
      memory[args[2]] = arg0 * arg1
    when 3 # in
      raise "input past end" unless inputs.any?
      memory[args[0]] = inputs.shift
    when 4 # out
      outputs << arg0
    when 5 # jnz
      jump_target = arg1 if arg0 != 0
    when 6 # jz
      jump_target = arg1 if arg0 == 0
    when 7 # lt
      memory[args[2]] = (arg0 < arg1) ? 1 : 0
    when 8 # eq
      memory[args[2]] = (arg0 == arg1) ? 1 : 0
    when 99
      break
    else
      raise "invalid opcode #{opcode} at position #{ip}"
    end

    if jump_target
      ip = jump_target
    else
      ip += argcount + 1
    end
  end
  outputs
end

program = ARGF.read.split(',').map(&:to_i).freeze
max_power = -1
max_phases = []

(0..4).to_a.permutation.each do |phases|
  input = 0
  phases.each do |phase|
    input = run(program.dup, [phase, input]).first
  end
  if input > max_power
    max_power = input
    max_phases = phases
  end
end

puts "#{max_phases.inspect} => #{max_power}"
