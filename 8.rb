WIDTH = 25
HEIGHT = 6
LAYER_SIZE = WIDTH * HEIGHT

image = ARGF.read.strip.chars
min_zeroes = LAYER_SIZE + 1
teh_layer = nil

image.each_slice(LAYER_SIZE) do |layer|
  zeroes = layer.count('0')
  if zeroes < min_zeroes
    teh_layer = layer
    min_zeroes = zeroes
  end
end

puts teh_layer.count('1') * teh_layer.count('2')