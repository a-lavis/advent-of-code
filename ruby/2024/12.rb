# frozen_string_literal: true

require_relative '2024'

content = CLI.get_content(12)

# ----------------------------------------------------------------------------
# Part 1 -

class Array
  def clip(n = 1) = take(size - n)
end

LINES = content.split("\n")

Plant = Data.define(:x, :y)

plant_type_index = LINES.each_with_index.reduce(Hash.new([])) do |index, (line, y)|
  line.chars.each_with_index.reduce(index) do |index, (char, x)|
    { **index, char => [*index[char], Plant.new(x, y)] }
  end
end

all_regions = plant_type_index.each_value.flat_map do |plants|
  plants.reduce([]) do |regions, plant|
    adjacent_regions = regions.filter do |region|
      region.any? do |checked_plant|
        (checked_plant.x == plant.x - 1 && checked_plant.y == plant.y) ||
          (checked_plant.x == plant.x && checked_plant.y == plant.y - 1)
      end
    end

    [
      *(regions - adjacent_regions),
      [
        *adjacent_regions.flatten,
        plant
      ]
    ]
  end
end

DELTAS = [[-1, 0], [0, -1], [1, 0], [0, -1]].freeze

part_1 = all_regions.sum do |region|
  area = region.size
  perimeter = region.sum do |plant|
    DELTAS.count do |dx, dy|
      region.none? do |plant_to_check|
        plant.x + dx == plant_to_check.x && plant.y + dy == plant_to_check.y
      end
    end
  end
  area * perimeter
end

puts "Part 1 (): #{part_1}"

# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Part 2 -

part_2 = "TODO"

puts "Part 2 (): #{part_2}"

# ----------------------------------------------------------------------------
