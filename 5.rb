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

def run(program)
  ip = 0
  while true
    instcode = program[ip]
    raise "nil opcode encountered" if instcode.nil?

    opcode = instcode % 100
    arg0imm = (instcode / 100) % 10 == 1
    arg1imm = (instcode / 1000) % 10 == 1

    argcount = ARGCOUNT[opcode] || 0
    args = program[ip + 1..ip + argcount]
    arg0 = (arg0imm ? args[0] : program[args[0]]) if argcount >= 1
    arg1 = (arg1imm ? args[1] : program[args[1]]) if argcount >= 2

    jump_target = nil
    case opcode
    when 1 # add
      program[args[2]] = arg0 + arg1
    when 2 # mul
      program[args[2]] = arg0 * arg1
    when 3 # in
      print "? "
      program[args[0]] = STDIN.readline.to_i
    when 4 # out
      puts arg0
    when 5 # jnz
      jump_target = arg1 if arg0 != 0
    when 6 # jz
      jump_target = arg1 if arg0 == 0
    when 7 # lt
      program[args[2]] = (arg0 < arg1) ? 1 : 0
    when 8 # eq
      program[args[2]] = (arg0 == arg1) ? 1 : 0
    when 99
      return
    else
      raise "invalid opcode #{opcode} at position #{ip}"
    end

    if jump_target
      ip = jump_target
    else
      ip += argcount + 1
    end
  end

end

program = File.read(ARGV.first).split(',').map(&:to_i)
run program

