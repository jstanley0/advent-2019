class Computer
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

  def initialize(program, inputs = [])
    @memory = program.dup
    @ip = 0
    @inputs = inputs
    @outputs = []
  end

  # returns the new instruction pointer, or nil if halted
  # consumes @inputs and produces @outputs
  def step
    instcode = @memory[@ip]
    raise "nil opcode encountered" if instcode.nil?

    opcode = instcode % 100
    arg0imm = (instcode / 100) % 10 == 1
    arg1imm = (instcode / 1000) % 10 == 1

    argcount = ARGCOUNT[opcode] || 0
    args = @memory[@ip + 1..@ip + argcount]
    arg0 = (arg0imm ? args[0] : @memory[args[0]]) if argcount >= 1
    arg1 = (arg1imm ? args[1] : @memory[args[1]]) if argcount >= 2

    jump_target = nil
    case opcode
    when 1 # add
      @memory[args[2]] = arg0 + arg1
    when 2 # mul
      @memory[args[2]] = arg0 * arg1
    when 3 # in
      raise "input past end" unless @inputs.any?
      @memory[args[0]] = @inputs.shift
    when 4 # out
      @outputs << arg0
    when 5 # jnz
      jump_target = arg1 if arg0 != 0
    when 6 # jz
      jump_target = arg1 if arg0 == 0
    when 7 # lt
      @memory[args[2]] = (arg0 < arg1) ? 1 : 0
    when 8 # eq
      @memory[args[2]] = (arg0 == arg1) ? 1 : 0
    when 99
      return nil
    else
      raise "invalid opcode #{opcode} at position #{@ip}"
    end

    if jump_target
      @ip = jump_target
    else
      @ip += argcount + 1
    end
  end

  # accepts an input and runs until an output is produced or the machine halts
  # returns the output, or nil if the machine halted
  def compute(input)
    @inputs << input
    while step
      return @outputs.shift if @outputs.any?
    end
    nil
  end
end

program = ARGF.read.split(',').map(&:to_i).freeze
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
