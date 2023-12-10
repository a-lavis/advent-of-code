# frozen_string_literal: true

require_relative '2023'

# Direction-related constants
module D
  DIRECTIONS = [
    NORTH = 'north',
    SOUTH = 'south',
    EAST = 'east',
    WEST = 'west'
  ].freeze

  TILE_TYPES = [
    NORTH_SOUTH = Set[NORTH, SOUTH].freeze,
    EAST_WEST = Set[EAST, WEST].freeze,
    NORTH_EAST = Set[NORTH, EAST].freeze,
    NORTH_WEST = Set[NORTH, WEST].freeze,
    SOUTH_WEST = Set[SOUTH, WEST].freeze,
    SOUTH_EAST = Set[SOUTH, EAST].freeze,
    NONE = Set[].freeze,
    ALL = Set[NORTH, SOUTH, EAST, WEST].freeze
  ].freeze

  CHAR_TO_TYPE = {
    '|' => NORTH_SOUTH,
    '-' => EAST_WEST,
    'L' => NORTH_EAST,
    'J' => NORTH_WEST,
    '7' => SOUTH_WEST,
    'F' => SOUTH_EAST,
    '.' => NONE,
    'S' => ALL
  }.freeze

  OPPOSITE = {
    NORTH => SOUTH,
    SOUTH => NORTH,
    EAST => WEST,
    WEST => EAST
  }.freeze

  TO_UNICODE = {
    [NORTH, SOUTH] => '↓',
    [SOUTH, NORTH] => '↑',
    [EAST, WEST] => '←',
    [WEST, EAST] => '→',
    [NORTH, EAST] => '↳',
    [EAST, NORTH] => '⬑',
    [NORTH, WEST] => '↲',
    [WEST, NORTH] => '⬏',
    [SOUTH, WEST] => '↰',
    [WEST, SOUTH] => '⬎',
    [SOUTH, EAST] => '↱',
    [EAST, SOUTH] => '⬐'
  }.freeze

  def self.move_coordinates(direction, row, column, distance = 1)
    case direction
    when D::NORTH
      [row - distance, column]
    when D::SOUTH
      [row + distance, column]
    when D::EAST
      [row, column + distance]
    when D::WEST
      [row, column - distance]
    else
      raise "Unrecognized direction: '#{direction}'."
    end
  end
end

Tile = Struct.new(:directions, :traversed, :filler, :open) do
  def self.from_char(char)
    Tile.new(directions: D::CHAR_TO_TYPE.fetch(char), traversed: false, open: false)
  end

  def self.new_filler
    Tile.new(directions: nil, traversed: false, filler: true)
  end

  def move_through(direction)
    if filler
      mark_traversal!(direction, direction)
      direction
    else
      raise 'Cannot be called on ground or animal.' if directions.length != 2

      options = directions.difference(Set[D::OPPOSITE.fetch(direction)])
      raise 'Direction not relevant to this tile.' if options.length != 1

      new_direction = options.first
      mark_traversal!(direction, new_direction)
      new_direction
    end
  end

  def mark_traversal!(from, to)
    self.traversed = D::TO_UNICODE.fetch([D::OPPOSITE.fetch(from), to])
  end
end

Coordinate = Data.define(:row, :column)

PipeSketch = Data.define(:tiles, :start) do
  def self.from_lines(lines)
    start = nil

    tiles = []

    lines.each_with_index do |line, row|
      row_of_tiles = []

      line.strip.chars.each_with_index do |c, column|
        if c == 'S'
          raise 'Two animals!' unless start.nil?

          start = Coordinate.new(row: row * 2, column: column * 2)
        end

        row_of_tiles << Tile.new_filler
        row_of_tiles << Tile.from_char(c)
      end

      tiles << Array.new(row_of_tiles.length - 1) { Tile.new_filler }.freeze
      tiles << row_of_tiles.drop(1).freeze
    end

    tiles = tiles.drop(1).freeze

    PipeSketch.new(tiles:, start:)
  end

  def furthest_distance_in_loop
    row = start.row
    column = start.column
    count = 0

    tile = tiles[row][column]
    valid_moves = valid_moves(tile, row, column)

    raise 'No moves found.' if valid_moves.empty?
    raise 'More than 2 options for a move.' if valid_moves.length > 2

    # arbitrarily pick a direction
    direction = valid_moves.first
    first_direction = direction

    row, column = D.move_coordinates(direction, row, column)
    tile = tiles[row][column]
    count += 1

    until row == start.row && column == start.column
      direction = tile.move_through(direction)
      row, column = D.move_coordinates(direction, row, column)
      raise 'Pipe ended unexpectedly.' if row.negative? || column.negative?

      count += 1 unless tile.filler
      tile = tiles[row][column]
    end

    tile.mark_traversal!(direction, first_direction)

    count / 2
  end

  def valid_moves(_tile, row, column)
    D::DIRECTIONS.map do |direction|
      new_row, new_column = D.move_coordinates(direction, row, column, 2)
      next if new_row.negative? || new_column.negative?
      next if new_row >= tiles.length || new_column >= tiles.first.length

      adjacent_tile = tiles[new_row][new_column]
      next unless adjacent_tile
      next unless adjacent_tile.directions.include?(D::OPPOSITE.fetch(direction))

      direction
    end.compact
  end

  def mark_all_open!
    try_again = true

    while try_again
      try_again = false

      0.upto(tiles.length - 1) do |row|
        0.upto(tiles[row].length - 1) do |column|
          marked_this_round = mark_open!(row, column)
          try_again ||= marked_this_round
        end
      end
    end
  end

  def mark_open!(row, column)
    tile = tiles[row][column]
    return false if tile.open # already marked as open

    tile.open = true if D::DIRECTIONS.any? do |direction|
      new_row, new_column = D.move_coordinates(direction, row, column, 1)
      next true if new_row.negative? || new_column.negative?
      next true if new_row >= tiles.length || new_column >= tiles.first.length

      adjacent_tile = tiles[new_row][new_column]
      next true unless adjacent_tile
      next false if adjacent_tile.traversed

      adjacent_tile.open
    end

    tile.open
  end

  def puts_pipe_loop_image
    tiles.each do |row_of_tiles|
      row = row_of_tiles.map do |tile|
        next tile.traversed if tile.traversed
        next '.' if tile.filler

        tile.open ? 'O' : 'I'
      end.join
      puts row
    end
  end

  def enclosed_count
    tiles.reduce(0) do |count, row_of_tiles|
      count + row_of_tiles.count do |tile|
        !tile.filler && !tile.open && !tile.traversed
      end
    end
  end
end

pipe_sketch = PipeSketch.from_lines(CLI.file_lines(10))

puts "Part 1: #{pipe_sketch.furthest_distance_in_loop}"

pipe_sketch.mark_all_open!
# pipe_sketch.puts_pipe_loop_image

puts "Part 2: #{pipe_sketch.enclosed_count}"
