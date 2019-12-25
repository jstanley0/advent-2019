require_relative 'computer'

def run
  loop do
    res = $reindeer.compute
    return res if res.nil? || res == :need_input
    if res < 128
      print res.chr
    else
      puts res
    end
  end
end

def interactive
  loop do
    res = run
    break if res.nil?
    $reindeer.ascii_input(STDIN.gets)
  end
end

def command(text)
  puts text
  $reindeer.ascii_input(text + "\n")
  result = ''
  loop do
    res = $reindeer.compute
    break if res == :need_input || res.nil?
    result += res.chr
  end
  puts result
  result
end

$reindeer = Computer.new
$reindeer.ascii_input(<<TAKE_STUFF)
east
take jam
east
take fuel cell
west
south
take shell
north
west
south
west
north
east
take space heater
west
south
take easter egg
west
west
take monolith
south
west
north
take coin
south
east
north
west
take mug
north
TAKE_STUFF

run

inv = ['jam', 'fuel cell', 'shell', 'space heater', 'easter egg', 'monolith', 'coin', 'mug']

inv.each { |item| command("drop #{item}") }

run

def permutation_command(inv, permutation, cmd)
  index = 0
  inv.each_with_index do |item, i|
    command("#{cmd} #{item}") if 0 != ((1 << i) & permutation)
  end
end

def take_items(inv, permutation)
  permutation_command(inv, permutation, "take")
end

def drop_items(inv, permutation)
  permutation_command(inv, permutation, "drop")
end

for permutation in 0...2 ** inv.size
  STDERR.puts "attempting permutation #{permutation}"
  take_items(inv, permutation)
  result = command("north")
  break unless result.include? 'ejected back to the checkpoint'
  drop_items(inv, permutation)
end
