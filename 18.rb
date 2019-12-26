require 'byebug'
require 'pqueue'

# something bigger than the largest expected solution
# but small enough so as not to slow down the math :P
LOTS = 1000000000

def find_char(maze, char)
  maze.each_with_index do |row, y|
    x = row.index(char)
    return [x, y] if x
  end
  nil
end

def dup_maze(source = nil)
  source ||= $maze
  source.map(&:dup)
end

Move = Struct.new(:key, :cost, :x, :y)

class State
  attr_reader :base_cost, :keys, :subset_mask

  def initialize(maze, loc, keys = "", cost = 0, subset_mask = 0)
    @maze = maze
    @keys = keys
    @base_cost = cost
    @loc = loc
    @subset_mask = subset_mask
    @moves = PQueue.new { |a, b| b.cost <=> a.cost }
  end

  # return a hash from key that can be collected to move cost
  def enum_moves
    @scratch = dup_maze(@maze)
    @cost = 1
    leading_edge = [@loc]
    loop do
      next_edge = []
      leading_edge.each do |x, y|
        next_edge.concat search_from(x, y)
      end
      break if next_edge.empty?
      leading_edge = next_edge
      @cost += 1
    end

    @moves
  end

  # return a new State after having taken the given key
  def apply_move(move)
    new_maze = dup_maze(@maze)
    new_maze[@loc[1]][@loc[0]] = '.'
    new_maze[move.y][move.x] = '@'
    new_subset = @subset_mask | (1 << (move.key.ord - 'a'.ord))
    State.new(new_maze, [move.x, move.y], @keys + move.key, @base_cost + move.cost, new_subset)
  end

  def print
    puts "Keys: #{@keys}  Base cost: #{@base_cost}  Cost estimate: #{cost_estimate}"
    puts @maze.join
    puts
  end

  # this must not overestimate the cost
  def cost_estimate
    @cost_estimate ||= furthest_key_distance
  end

private

  def visit_cell(x, y)
    if @scratch[y][x] == '.'
      @scratch[y][x] = ' '
      return x, y
    elsif ('a'..'z').include?(@scratch[y][x])
      @moves.push Move.new(@scratch[y][x], @cost, x, y)
      return nil
    elsif ('A'..'Z').include?(@scratch[y][x])
      return nil unless @keys.include?(@scratch[y][x].downcase)
      @scratch[y][x] = ' '
      return x, y
    end
    nil
  end

  def search_from(x, y)
    frontier = []
    frontier << visit_cell(x - 1, y)
    frontier << visit_cell(x, y - 1)
    frontier << visit_cell(x + 1, y)
    frontier << visit_cell(x, y + 1)
    frontier.compact
  end

  def furthest_key_distance
    r = 0
    @maze.each_with_index do |row, y|
      for x in 0...row.size
        if ('a'..'z').include? row[x]
          d = manhattan_distance(x, y)
          r = d if d > r
        end
      end
    end
    r
  end

  def manhattan_distance(x, y)
    (@loc[0] - x).abs + (@loc[1] - y).abs
  end
end

def prune_subtree?(at_key, cost_so_far, key_subset)
  $best_subset_costs[at_key] ||= {}
  juncture_cost = $best_subset_costs[at_key][key_subset] || LOTS
  if cost_so_far < juncture_cost
    $best_subset_costs[at_key][key_subset] = cost_so_far
  end
  return cost_so_far > juncture_cost
end


$maze = ARGF.readlines.map(&:freeze).freeze

$best_cost = LOTS
$best_subset_costs = {}

pq = PQueue.new { |a, b| b.cost_estimate <=> a.cost_estimate }
pq.push State.new(dup_maze, find_char($maze, '@'))
until pq.empty?
  state = pq.pop
  # state.print

  next if state.cost_estimate > $best_cost

  moves = state.enum_moves
  if moves.empty?
    if state.base_cost < $best_cost
      puts "solution found: #{state.base_cost} #{state.keys}"
      $best_cost = state.base_cost
    end
  end

  moves.each_pop do |move|
    next if state.base_cost + move.cost >= $best_cost
    next if prune_subtree?(move.key, state.base_cost + move.cost, state.subset_mask)
    substate = state.apply_move(move)
    pq.push(substate)
  end
end

