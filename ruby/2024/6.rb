# frozen_string_literal: true

require_relative '2024'

content = CLI.get_content(6)
lines = content.split("\n")

# ----------------------------------------------------------------------------
# Part 1 -

starting_state = lines.each_with_index.reduce(nil) do |_, (line, y)|
  result = line.chars.each_with_index.reduce(nil) do |_, (char, x)|
    direction = case char
      when '^'
        :up
      when '>'
        :right
      when '<'
        :left
      when 'v'
        :down
      end

    break { direction:, x:, y: } if direction
  end

  break result if result
end

y_bound = lines.length
x_bound = lines[0].length

part_1 = (0..).reduce({
  **starting_state,
  counted_coords: Set[]
}) do |state, _|
  state => { counted_coords:, direction:, x:, y: }

  new_counted_coords = Set[ *counted_coords, [x, y] ]

  case direction
  when :left
    [:up, x - 1, y]
  when :up
    [:right, x, y - 1]
  when :right
    [:down, x + 1, y]
  when :down
    [:left, x, y + 1]
  end => [new_direction, new_x, new_y]

  if !(0 <= new_y && new_y < y_bound && 0 <= new_x && new_x < x_bound)
    break new_counted_coords.length
  elsif lines[new_y][new_x] == '#'
    { counted_coords: new_counted_coords, direction: new_direction, x:, y: }
  else
    { counted_coords: new_counted_coords, direction:, x: new_x, y: new_y }
  end
end

puts "Part 1 (): #{part_1}"

# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Part 2 -

part_2 = "TODO"

puts "Part 2 (): #{part_2}"

# ----------------------------------------------------------------------------
