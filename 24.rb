require 'set'

def calculate_biodiversity(board)
  bd = 0
  bit = 1
  board.each do |row|
    for i in 0...row.size
      bd += bit if row[i] == '#'
      bit <<= 1
    end
  end
  bd
end

def run_life(board)
  new_board = board.map(&:dup)
  h = board.size
  w = board[0].size
  for y in 0...h
    for x in 0...w
      n = 0
      n += 1 if y > 0 && board[y - 1][x] == '#'
      n += 1 if y < h - 1 && board[y + 1][x] == '#'
      n += 1 if x > 0 && board[y][x - 1] == '#'
      n += 1 if x < w - 1 && board[y][x + 1] == '#'
      if board[y][x] == '#'
        new_board[y][x] = '.' unless n == 1
      else
        new_board[y][x] = '#' if n == 1 || n == 2
      end
    end
  end
  new_board
end

board = ARGF.readlines.map(&:strip)
observed_biodiversity = Set.new

loop do
  b = calculate_biodiversity(board)
  puts "score #{b}:"
  puts board.join("\n")
  if observed_biodiversity.include?(b)
    puts b
    break
  end
  observed_biodiversity << b
  board = run_life board
end
