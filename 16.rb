require 'byebug'

def gen_mul_matrix(size)
  $mul_matrix = []
  for i in 1..size
    row = []
    while row.size <= size
      row += [0] * i
      row += [1] * i
      row += [0] * i
      row += [-1] * i
    end
    row = row[1..size]
    $mul_matrix << row
  end
end

def fft_phase(input)
  output = []
  input.each_index do |i|
    sum = 0
    input.each_with_index do |n, j|
      sum += n * $mul_matrix[i][j]
    end
    output << sum.abs % 10
  end
  output
end

input = ARGF.read.strip
raise 'bad input' unless input =~ /\A\d+\z/
input = input.chars.map { |char| char.ord - '0'.ord }

gen_mul_matrix(input.size)

phases = 100
while phases > 0
  input = fft_phase input
  #puts input.inspect
  phases -= 1
end

puts input.inspect