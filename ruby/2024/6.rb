# frozen_string_literal: true

require_relative '2024'

content = CLI.get_content(6)
starting_lines = content.split("\n")

# ----------------------------------------------------------------------------
# Part 1 -

GUARD_CHARS = [
  UP = '^',
  RIGHT = '>',
  LEFT = '<',
  DOWN = 'v'
].freeze

starting_state = starting_lines.each_with_index.reduce(nil) do |_, (line, y)|
  result = line.chars.each_with_index.reduce(nil) do |_, (char, x)|
    break { direction: char, x:, y: } if GUARD_CHARS.include?(char)
  end

  break result if result
end

STARTING_DIRECTION = starting_state[:direction]
STARTING_X = starting_state[:x]
STARTING_Y = starting_state[:y]

Y_BOUND = starting_lines.length
X_BOUND = starting_lines[0].length

def patrol(lines)
  ls = lines
  direction = STARTING_DIRECTION
  x = STARTING_X
  y = STARTING_Y
  vectors = Set[]

  while true do
    vector = { direction:, x:, y: }

    break { loop: true, vectors: nil } if vectors.include?(vector)

    vectors = Set[ *vectors, vector ]

    case direction
    when LEFT
      [UP, x - 1, y]
    when UP
      [RIGHT, x, y - 1]
    when RIGHT
      [DOWN, x + 1, y]
    when DOWN
      [LEFT, x, y + 1]
    end => [new_direction, new_x, new_y]
    
    if !(0 <= new_y && new_y < Y_BOUND && 0 <= new_x && new_x < X_BOUND)
      break { loop: false, vectors: }
    end

    if ls[new_y][new_x] == '#'
      direction = new_direction
      next
    end

    x = new_x
    y = new_y
  end
end

patrol(starting_lines) => { vectors: }

coords = vectors.map do |vector|
  vector => { x:, y: }
  { x:, y: }
end.uniq

part_1 = coords.length

puts "Part 1 (): #{part_1}"

# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Part 2 -

i = 0
coords_length = coords.length

part_2 = coords.count do |coord|
  coord => { x:, y: }

  i += 1
  puts(
    "x: #{x}, y: #{y}, progress: #{i}/#{coords_length} " \
    "(#{((i.to_f/coords_length)*100).round(2)}%)"
  )

  next false if x == STARTING_X && y == STARTING_Y

  starting_lines[y][x] = '#'

  result = patrol(
    starting_lines
  )[:loop]

  starting_lines[y][x] = '.'

  result
end

puts "Part 2 (): #{part_2}"

# ----------------------------------------------------------------------------
