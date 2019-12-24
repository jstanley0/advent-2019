ADJACENCY = [
{ 0 => [1, 5], -1 => [11, 7] }, # 0
{ 0 => [0, 2, 6], -1 => [7] }, # 1
{ 0 => [1, 3, 7], -1 => [7] }, # 2
{ 0 => [2, 4, 8], -1 => [7] }, # 3
{ 0 => [3, 9], -1 => [7, 13] }, # 4

{ 0 => [0, 6, 10], -1 => [11] }, # 5
{ 0 => [1, 5, 7, 11] }, # 6
{ 0 => [2, 6, 8], 1 => [0, 1, 2, 3, 4] }, # 7
{ 0 => [3, 7, 9, 13] }, # 8
{ 0 => [4, 8, 14], -1 => [13] }, # 9

{ 0 => [5, 11, 15], -1 => [11] }, # 10
{ 0 => [6, 10, 16], 1 => [0, 5, 10, 15, 20] }, # 11
{ 0 => [] }, # 12
{ 0 => [8, 14, 18], 1 => [4, 9, 14, 19, 24] }, # 13
{ 0 => [9, 13, 19], -1 => [13] }, # 14

{ 0 => [10, 16, 20], -1 => [11] }, # 15
{ 0 => [11, 15, 17, 21] }, # 16
{ 0 => [16, 18, 22], 1 => [20, 21, 22, 23, 24] }, # 17
{ 0 => [13, 17, 19, 23] }, # 18
{ 0 => [14, 18, 24], -1 => [13] }, # 19

{ 0 => [15, 21], -1 => [11, 17] }, # 20
{ 0 => [16, 20, 22], -1 => [17] }, # 21
{ 0 => [17, 21, 23], -1 => [17] }, # 22
{ 0 => [18, 22, 24], -1 => [17] }, # 23
{ 0 => [19, 23], -1 => [13, 17] }, # 24
]

def print_boards(boards)
  boards.each { |board| print "%5s " % board[25..-1] }
  puts
  pos = 0
  while pos < 25
    boards.each { |board| print board[pos..pos+4] + ' ' }
    puts
    pos += 5
  end
  puts
end

def blank_board(template, diff)
  num = template[25..-1].to_i + diff
  "............?............" + num.to_s
end

def count_adjacent_bugs(boards, board_num, i)
  adj = 0
  ADJACENCY[i].each do |relative_board, adjacent_indices|
    board_index = board_num + relative_board
    if (0...boards.size).include? board_index
      adjacent_indices.each do |j|
        adj += 1 if boards[board_index][j] == '#'
      end
    end
  end
  adj
end

def run_life(boards)
  boards.unshift blank_board(boards.first, -1)
  boards.push blank_board(boards.last, 1)
  next_gen = boards.map(&:dup)
  next_gen.each_with_index do |board, board_index|
    for i in 0..24
      adj = count_adjacent_bugs(boards, board_index, i)
      if board[i] == '#'
        board[i] = '.' unless adj == 1
      elsif board[i] == '.'
        board[i] = '#' if adj == 1 || adj == 2
      end
    end
  end
  # don't expand needlessly
  next_gen.shift if next_gen.first.count('#') == 0
  next_gen.pop if next_gen.last.count('#') == 0
  next_gen
end

def count_bugs(boards)
  boards.map { |board| board.count('#') }.inject(:+)
end

board = ARGF.readlines.map(&:strip).join
raise "bad board" unless board.size == 25
board[12] = '?'
board += "0"

boards = [board]
for t in 0..10
  puts "t=#{t}; population=#{count_bugs(boards)}"
  print_boards(boards)
  boards = run_life(boards)
end
