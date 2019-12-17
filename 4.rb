# okay this is ridiculously lame but I am too sleep-deprived to think through it properly

RANGE = (152085..670283)

def valid?(num)
  s = num.to_s
  dub = false
  (1..5).each do |i|
    return false if s[i] < s[i - 1]
    dub = true if s[i] == s[i - 1]
  end
  dub
end

count = 0
RANGE.each { |num| count += 1 if valid?(num) }

puts count