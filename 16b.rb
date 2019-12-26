input = ARGF.read.strip
raise 'bad input' unless input =~ /\A\d+\z/

offset = input[0...7].to_i
puts "offset = #{offset}"

input = input * 10000
raise "special case constraint violation" if offset < input.size / 2

input = input[offset..-1].chars.map { |char| char.ord - '0'.ord }

def fake_fft_phase(input)
  sum = 0
  output = []
  i = input.size - 1
  while i >= 0
    sum += input[i]
    output[i] = sum % 10
    i -= 1
  end
  output
end

100.times do
  input = fake_fft_phase(input)
end

puts input[0...8].join