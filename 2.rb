
def run(program)
  ip = 0
  while true
    opcode = program[ip]
    raise "nil opcode encountered" if opcode.nil?
    args = program[ip + 1..ip + 3]
    case opcode
    when 1
      program[args[2]] = program[args[0]] + program[args[1]]
    when 2
      program[args[2]] = program[args[0]] * program[args[1]]
    when 99
      return
    else
      raise "invalid opcode: #{opcode} at position #{ip}"
    end
    ip += 4
  end

end

program = STDIN.read.split(',').map(&:to_i)

(0..99).each do |noun|
  (0..99).each do |verb|
    copy = program.dup
    copy[1] = noun
    copy[2] = verb
    run copy
    puts noun * 100 + verb if copy[0] == 19690720
  end
end
