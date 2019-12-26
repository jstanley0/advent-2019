require 'byebug'
require 'pqueue'
require 'pp'

# something bigger than the largest expected solution
# but small enough so as not to slow down the math :P
LOTS = 1000000000

class Connection
  attr_accessor :cost, :reqs, :passed_by

  def initialize(cost, reqs, passed_by)
    @cost = cost
    @reqs = reqs
    @passed_by = passed_by
  end

  def inspect
    "cost=#{cost} reqs=#{letter_set(@reqs)} passed_by=#{letter_set(@passed_by).downcase}"
  end

  private

  def letter_set(bits)
    letters = ''
    ('A'..'Z').each_with_index do |l, i|
      letters += l if (bits & (1 << i)) != 0
    end
    letters
  end
end

class Maze
  def initialize
    @maze = ARGF.readlines.map(&:freeze).freeze
    locate_keys
    locate_robot
    build_graph
    #pp @map
  end

  def connections_from(key, subset_mask)
    @map[key].each do |dest, connection|
      # skip keys we already possess
      next if subset_mask & Maze.key_bit(dest) != 0
      # skip keys that are beyond other keys we *don't* already possess
      # i.e. any bit is 1 in passed_by but is 0 in subset_mask
      next if (connection.passed_by & ~subset_mask) != 0
      # skip keys we can't reach
      next unless (connection.reqs & subset_mask) == connection.reqs

      yield dest, connection.cost
    end
    nil
  end

  # note that this does not consider whether the key is currently reachable
  # we just need a lower bound on the remaining cost of this path
  def furthest_key_distance(key, subset_mask)
    @map[key].reverse_each do |dest, connection|
      next if subset_mask & Maze.key_bit(dest) != 0
      return connection.cost
    end
    0
  end

  def key_count
    @keys.size
  end

  def complete?(mask)
    mask == @complete_mask
  end

  private

  def build_graph
    @map = {}
    bfs(@robot[0], @robot[1], '@')
    @keys.each do |key, loc|
      bfs(loc[0], loc[1], key)
    end
    nil
  end

  def bfs(x, y, origin)
    make_scratch_maze
    @scratch[y][x] = '.'
    @origin = origin
    @map[@origin] = {}
    @cost = 1
    leading_edge = [[x, y, 0, 0]]
    loop do
      next_edge = []
      leading_edge.each do |x, y, reqs, passed_by|
        next_edge.concat search_from(x, y, reqs, passed_by)
      end
      break if next_edge.empty?
      leading_edge = next_edge
      @cost += 1
    end
  end

  def self.key_bit(key)
    (1 << (key.ord - 'a'.ord))
  end

  def self.door_bit(door)
    (1 << (door.ord - 'A'.ord))
  end

  def visit_cell(x, y, reqs, passed_by)
    c = @scratch[y][x]
    case c
    when '.', '@'
      space = true
    when 'a'..'z'
      key = true
    when 'A'..'Z'
      door = true
    end
    return nil unless space || key || door

    reqs |= Maze.door_bit(c) if door
    if key
      @map[@origin][c] = Connection.new(@cost, reqs, passed_by)
      passed_by |= Maze.key_bit(c)
    end

    @scratch[y][x] = ' '
    return x, y, reqs, passed_by
  end

  def search_from(x, y, reqs, passed_by)
    frontier = []
    frontier << visit_cell(x - 1, y, reqs, passed_by)
    frontier << visit_cell(x, y - 1, reqs, passed_by)
    frontier << visit_cell(x + 1, y, reqs, passed_by)
    frontier << visit_cell(x, y + 1, reqs, passed_by)
    frontier.compact
  end

  def find_char(char)
    @maze.each_with_index do |row, y|
      x = row.index(char)
      return [x, y] if x
    end
    nil
  end

  def locate_robot
    @robot = find_char('@')
  end

  def locate_keys
    @keys = {}
    @complete_mask = 0
    @maze.each_with_index do |row, y|
      for x in 0...row.size
        if ('a'..'z').include?(row[x])
          @keys[row[x]] = [x, y]
          @complete_mask |= Maze.key_bit(row[x])
        end
      end
    end
  end

  def make_scratch_maze
    @scratch = @maze.map(&:dup)
  end
end

class State
  attr_reader :base_cost, :keys, :subset_mask

  def initialize(maze, start_key = '@', keys = "", cost = 0, subset_mask = 0)
    @at = start_key
    @maze = maze
    @keys = keys
    @base_cost = cost
    @subset_mask = subset_mask
  end

  def complete?
    @maze.complete?(@subset_mask)
  end

  # return a hash from collectable key to move cost
  def enum_paths(&block)
    @maze.connections_from(@at, @subset_mask, &block)
  end

  # return a new State after having taken the given key
  def apply_move(key, cost)
    State.new(@maze, key, @keys + key, @base_cost + cost, @subset_mask | Maze.key_bit(key))
  end

  def print
    puts "At #{@at}  Keys: #{@keys}  Base cost: #{@base_cost}  Cost estimate: #{cost_estimate}"
  end

  # this must not overestimate the cost
  def cost_estimate
    @cost_estimate ||= @base_cost + @maze.furthest_key_distance(@at, @subset_mask)
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

$best_cost = LOTS
$best_subset_costs = {}

def depth_charge(state, greedy = false)
  return if state.cost_estimate > $best_cost

  if state.complete?
    if state.base_cost < $best_cost
      puts "#{greedy ? "greedy" : "random"} solution found: #{state.base_cost} #{state.keys}"
      $best_cost = state.base_cost
    end
  else
    substates = []
    state.enum_paths do |key, cost|
      substates << [key, cost]
      break if greedy
    end
    key, cost = substates.sample
    return if state.base_cost + cost >= $best_cost
    return if prune_subtree?(key, state.base_cost + cost, state.subset_mask)
    depth_charge(state.apply_move(key, cost), greedy)
  end
end

maze = Maze.new
start_state = State.new(maze)

# run the greedy solution first, for the lulz
depth_charge(start_state, true)

# make some random depth-first runs to prime the pruning shears
[maze.key_count ** 4, 1000000].min.times do
  depth_charge(start_state)
end

# now run the breadth-first search
pq = PQueue.new { |a, b| b.cost_estimate <=> a.cost_estimate }
pq.push start_state
until pq.empty?
  state = pq.pop
  #state.print
  next if state.cost_estimate > $best_cost

  if state.complete?
    if state.base_cost < $best_cost
      puts "BFS solution found: #{state.base_cost} #{state.keys}"
      $best_cost = state.base_cost
    end
  else
    state.enum_paths do |key, cost|
      next if state.base_cost + cost >= $best_cost
      next if prune_subtree?(key, state.base_cost + cost, state.subset_mask)
      pq.push(state.apply_move(key, cost))
    end
  end
end

