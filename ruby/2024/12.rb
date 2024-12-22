# frozen_string_literal: true

require_relative '2024'

content = CLI.get_content(12)

# ----------------------------------------------------------------------------
# Part 1 -

class Array
  def clip(n = 1) = take(size - n)
end

LINES = content.split("\n")

Plant = Data.define(:x, :y) do
  def any_plant_adjacent?(region, dx, dy)
    region.any? { |other_plant| plant_adjacent?(other_plant, dx, dy) }
  end

  def plant_adjacent?(other_plant, dx, dy)
    x + dx == other_plant.x && y + dy == other_plant.y
  end
end

plant_type_index = LINES.each_with_index.reduce(Hash.new([])) do |index, (line, y)|
  line.chars.each_with_index.reduce(index) do |index, (char, x)|
    { **index, char => [*index[char], Plant.new(x, y)] }
  end
end

ALL_REGIONS = plant_type_index.each_value.flat_map do |plants|
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

def calculate_price
  ALL_REGIONS.sum do |region|
    area = region.size
    price_multiplier = yield region 
    area * price_multiplier
  end
end

part_1 = calculate_price do |region|
  # calculate perimeter of region
  region.sum do |plant|
    DELTAS.count do |dx, dy|
      !plant.any_plant_adjacent?(region, dx, dy)
    end
  end
end

puts "Part 1 (): #{part_1}"

# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Part 2 -

Side = Data.define(:plants) do
  def self.from_plant(plant)
    new([plant])
  end

  def plant_adjacent?(plant, dx, dy)
    plants.any? { |own_plant| plant.x == own_plant.x + dx && plant.y == own_plant.y + dy }
  end

  def with_plant(plant)
    Side.new([*plants, plant])
  end
end

part_2 = calculate_price do |region|
  # calculate number of sides of region
  
  result = region.reduce([]) do |old_sides, plant|
    edges = DELTAS
      .map { |dx, dy| Plant.new(plant.x + dx, plant.y + dy) }
      .filter do |edge|
        edge.x
        region.none? do |other_plant|
          other_plant.x == edge.x && other_plant.y == edge.y
        end
      end

    old_sides.reduce(new_sides: [], edges:) do |acc, old_side|
      acc => {new_sides:, edges:}
      same_edge = edges.find do |edge|
        DELTAS.any? do |dx, dy|
          old_side.plant_adjacent?(edge, dx, dy)
        end
      end

      if same_edge
        {
          new_sides: [*new_sides, old_side.with_plant(same_edge)],
          edges: edges - [same_edge]
        }
      else
        { **acc, new_sides: [*new_sides, old_side] }
      end
    end => {new_sides:, edges:}

    [*new_sides, *(edges.map { |edge| Side.from_plant(edge) })]
  end

  binding.irb

  result.size
end

puts "Part 2 (): #{part_2}"

# ----------------------------------------------------------------------------
