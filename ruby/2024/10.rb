# frozen_string_literal: true

require_relative '2024'

content = CLI.get_content(10)

# ----------------------------------------------------------------------------
# Part 1 -

LINES = content.split("\n").freeze

TOPO = LINES.map do |line|
  line.chars.map(&:to_i).freeze
end.freeze

HEIGHT = TOPO.size
WIDTH = TOPO[0].size
DELTAS = [[-1, 0], [0, -1], [1, 0], [0, 1]].freeze

TrailSection = Data.define(:x, :y, :expected_elevation) do
  def each_delta
    DELTAS.map do |dx, dy|
      yield TrailSection.new(x + dx, y + dy, expected_elevation + 1)
    end
  end

  def status
    return :failure if x < 0 || x >= WIDTH || y < 0 || y >= HEIGHT
    return :failure if TOPO[y][x] != expected_elevation

    :success if expected_elevation == 9
  end

  def nines
    case status
    when :failure
      []
    when :success
      [[x, y]]
    else
      each_delta(&:nines).flatten(1).uniq
    end
  end

  def rating
    case status
    when :failure
      0
    when :success
      1
    else
      each_delta(&:rating).sum
    end
  end

  def score = nines.length
end

trailheads = TOPO.each_with_index.flat_map do |line, y|
  line.each_with_index.filter_map do |char, x|
    next unless char == 0

    TrailSection.new(x, y, 0)
  end
end

part_1 = trailheads.sum(&:score)

puts "Part 1 (): #{part_1}"

# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Part 2 -

part_2 = trailheads.sum(&:rating)

puts "Part 2 (): #{part_2}"

# ----------------------------------------------------------------------------
