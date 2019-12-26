require 'byebug'
require 'pqueue'

# something bigger than the largest expected solution
# but small enough so as not to slow down the math :P
LOTS = 1000000000

def find_char(maze, char)
  occurrences = []
  maze.each_with_index do |row, y|
    x0 = 0
    loop do
      x = row.index(char, x0)
      if x
        occurrences << [x, y]
        x0 = x + 1
      else
        break
      end
    end
  end
  occurrences
end

def dup_maze(source = nil)
  source ||= $maze
  source.map(&:dup)
end

Move = Struct.new(:key, :cost, :x, :y, :robot)

class State
  attr_reader :base_cost, :keys, :subset_mask

  def initialize(maze, robot_locations, keys = "", cost = 0, subset_mask = 0)
    @maze = maze
    @keys = keys
    @base_cost = cost
    @locs = robot_locations
    @subset_mask = subset_mask
    @moves = PQueue.new { |a, b| b.cost <=> a.cost }
  end

  # return a hash from key that can be collected to move cost
  def enum_moves
    @scratch = dup_maze(@maze)
    @locs.each_with_index do |loc, robot|
      @cost = 1
      leading_edge = [loc]
      loop do
        next_edge = []
        leading_edge.each do |x, y|
          next_edge.concat search_from(x, y, robot)
        end
        break if next_edge.empty?
        leading_edge = next_edge
        @cost += 1
      end
    end

    @moves
  end

  # return a new State after having taken the given key
  def apply_move(move)
    new_maze = dup_maze(@maze)
    new_maze[@locs[move.robot][1]][@locs[move.robot][0]] = '.'
    new_maze[move.y][move.x] = ('0'.ord + move.robot).chr
    new_locs = @locs.dup
    new_locs[move.robot] = [move.x, move.y]
    new_subset = @subset_mask | (1 << (move.key.ord - 'a'.ord))
    State.new(new_maze, new_locs, @keys + move.key, @base_cost + move.cost, new_subset)
  end

  def print
    puts "Keys: #{@keys}  Base cost: #{@base_cost} "
    puts @maze.join
    puts
  end

private

  def visit_cell(x, y, robot)
    if @scratch[y][x] == '.'
      @scratch[y][x] = ' '
      return x, y
    elsif ('a'..'z').include?(@scratch[y][x])
      @moves.push Move.new(@scratch[y][x], @cost, x, y, robot)
      return nil
    elsif ('A'..'Z').include?(@scratch[y][x])
      return nil unless @keys.include?(@scratch[y][x].downcase)
      @scratch[y][x] = ' '
      return x, y
    end
    nil
  end

  def search_from(x, y, robot)
    frontier = []
    frontier << visit_cell(x - 1, y, robot)
    frontier << visit_cell(x, y - 1, robot)
    frontier << visit_cell(x + 1, y, robot)
    frontier << visit_cell(x, y + 1, robot)
    frontier.compact
  end
end

$maze = ARGF.readlines.map(&:freeze).freeze

$best_cost = LOTS
$best_subset_costs = {}

pq = PQueue.new { |a, b| a.keys.size <=> b.keys.size }
pq.push State.new(dup_maze, find_char($maze, '@'))
until pq.empty?
  state = pq.pop
  #state.print

  next if state.base_cost > $best_cost

  moves = state.enum_moves
  if moves.empty?
    if state.base_cost < $best_cost
      puts "solution found: #{state.base_cost} #{state.keys}"
      $best_cost = state.base_cost
    end
  end

  moves.each_pop do |move|
    next if state.base_cost + move.cost >= $best_cost
    substate = state.apply_move(move)
    pq.push(substate)
  end
end

