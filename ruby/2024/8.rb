# frozen_string_literal: true

require_relative '2024'

content = CLI.get_content(8)

# ----------------------------------------------------------------------------
# Part 1 -

Point = Data.define(:x, :y)
Antenna = Data.define(:point, :frequency)

lines = content.split("\n")

HEIGHT = lines.length
WIDTH = lines[0].length

antennas = lines.each_with_index.flat_map do |line, y|
  line.chars.each_with_index.filter_map do |char, x|
    Antenna.new(Point.new(x, y), char) if char.match?(/[A-Za-z0-9]/)
  end
end.to_set

def transform_coordinate(starting_coord, antenna_coord)
  (antenna_coord - starting_coord) + antenna_coord
end

part_1 = (0...HEIGHT).sum do |y|
  (0...WIDTH).count do |x|
    antennas.any? do |antenna|
      point = antenna.point
      next false if point.x == x && point.y == y

      new_y = transform_coordinate(y, point.y)
      next false unless 0 <= new_y && new_y < HEIGHT

      new_x = transform_coordinate(x, point.x)
      next false unless 0 <= new_x && new_x < WIDTH

      lines[new_y][new_x] == antenna.frequency
    end
  end
end

puts "Part 1 (): #{part_1}"

# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Part 2 -

part_2 = (0...HEIGHT).sum do |y|
  (0...WIDTH).count do |x|
    antennas.any? do |antenna|
      point = antenna.point
      next true if point.x == x && point.y == y

      d_y = point.y - y
      d_x = point.x - x
      gcd = d_y.gcd(d_x)
      d_y /= gcd
      d_x /= gcd

      i = 0
      while true
        new_y = y + (i * d_y)
        break false unless 0 <= new_y && new_y < HEIGHT

        new_x = x + (i * d_x)
        break false unless 0 <= new_x && new_x < WIDTH

        if (
            lines[new_y][new_x] == antenna.frequency &&
            !(new_y == point.y && new_x == point.x)
        )
          break true
        end

        i += 1
      end
    end
  end
end

puts "Part 2 (): #{part_2}"

# ----------------------------------------------------------------------------
