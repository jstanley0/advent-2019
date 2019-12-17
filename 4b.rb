# still lame

RANGE = (152085..670283)

def valid?(num)
  s = num.to_s
  groups = [s[0]]
  s[1..-1].chars.each do |char|
    last_char = groups[-1][-1]
    if char == last_char
      groups[-1] << char
    else
      return false if char < last_char
      groups << char
    end
  end
  groups.any? { |group| group.length == 2 }
end

count = 0
RANGE.each { |num| count += 1 if valid?(num) }

puts count