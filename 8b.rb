WIDTH = 25
HEIGHT = 6
LAYER_SIZE = WIDTH * HEIGHT

image = ARGF.read.strip.chars
min_zeroes = LAYER_SIZE + 1
teh_layer = nil

layers = image.each_slice(LAYER_SIZE).to_a
flattened_image = layers.shift

layers.each do |layer|
  flattened_image.each_with_index do |val, index|
    flattened_image[index] = layer[index] if val == '2'
  end
end

flattened_image.each_slice(WIDTH) do |row|
  puts row.map { |px| px == '1' ? '*' : ' ' }.join
end