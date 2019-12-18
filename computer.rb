class Computer
  TRACE = false

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
    1,  # base
  ]

  def initialize(program = nil, inputs = [])
    @memory = if program
      if program.is_a?(Array)
        program.dup
      else
        parse_program(program)
      end
    else
      parse_program(infer_program)
    end
    @ip = 0
    @base = 0
    @inputs = inputs
    @outputs = []
  end

  # returns the new instruction pointer, or nil if halted
  # consumes @inputs and produces @outputs
  def step
    instcode = @memory[@ip]
    raise "nil opcode encountered" if instcode.nil?

    opcode = instcode % 100
    argcount = ARGCOUNT[opcode] || 0
    addressing_modes = argcount.times.map { |ix| (instcode / (10 ** (ix + 2))) % 10 }
    args = addressing_modes.each_with_index.map do |am, ix|
      raw_arg = @memory[@ip + ix + 1] #|| 0
      translate_arg(opcode, ix, raw_arg, am)
    end

    if TRACE
      STDERR.puts "@ip=#{@ip} @base=#{@base} inst=#{@memory[@ip..@ip+argcount].inspect} opcode=#{opcode} am=#{addressing_modes.inspect} args=#{args.inspect}"
    end

    jump_target = nil
    case opcode
    when 1 # add
      @memory[args[2]] = args[0] + args[1]
    when 2 # mul
      @memory[args[2]] = args[0] * args[1]
    when 3 # in
      @memory[args[0]] = @inputs.any? ? @inputs.shift : get_input
    when 4 # out
      @outputs << args[0]
    when 5 # jnz
      jump_target = args[1] if args[0] != 0
    when 6 # jz
      jump_target = args[1] if args[0] == 0
    when 7 # lt
      @memory[args[2]] = (args[0] < args[1]) ? 1 : 0
    when 8 # eq
      @memory[args[2]] = (args[0] == args[1]) ? 1 : 0
    when 9 #base
      @base += args[0]
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

  def get_input
    print "? "
    STDIN.gets.to_i
  end

  def run_interactive
    loop do
      output = compute
      break if output.nil?
      puts output
    end
  end

  # accepts an input and runs until an output is produced or the machine halts
  # returns the output, or nil if the machine halted
  def compute(*inputs)
    @inputs.concat(inputs)
    while step
      return @outputs.shift if @outputs.any?
    end
    nil
  end

  private

  def infer_program
    if ARGV.length == 1
      File.read(ARGV.first)
    else
      print "enter program: "
      STDIN.readline
    end
  end

  def parse_program(program)
    program.split(',').map(&:to_i)
  end

  def lvalue?(opcode, index)
    case opcode
    when 1, 2, 7, 8 # add, mul, lt, eq
      index == 2
    when 3
      index == 0    # in
    end
  end

  def validate_address!(address)
    raise "attempted to access invalid address #{address} at position #{@ip}" if address < 0
  end

  def translate_arg(opcode, index, raw_arg, addressing_mode)
    lv = lvalue?(opcode, index)
    case addressing_mode
    when 0 # positional
      validate_address!(raw_arg)
      lv ? raw_arg : (@memory[raw_arg] || 0)
    when 1 # immediate
      lv ? raise("attempted to use immediate as lvalue at position #{@ip}") : raw_arg
    when 2 # relative
      address = @base + raw_arg
      validate_address!(address)
      lv ? address : (@memory[address] || 0)
    else
      raise "invalid addressing mode #{addressing_mode} at position #{@ip}"
    end
  end

end