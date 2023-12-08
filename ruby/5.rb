# frozen_string_literal: true

argv = ARGV

raise 'I need exactly one argument' if argv.length != 1

filename = argv[0]

raise 'First argument must be a filename of a file that exists' unless File.exist?(filename)

file = File.open(filename)
content = file.readlines
file.close

MapRange = Data.define(:destination, :source, :length) do
  def source_range
    source..source + length - 1
  end

  def include?(source_value)
    source_range.include?(source_value)
  end

  def corresponding_for(source_value)
    delta = source_value - source
    destination + delta
  end
end

Map = Data.define(:ranges) do
  def corresponding_for(source_value)
    range = ranges.find { |r| r.include?(source_value) }

    return source_value if range.nil?

    range.corresponding_for(source_value)
  end
end

Almanac = Data.define(:seeds, :maps) do
  def self.from_lines(content)
    _, *number_strings = content.reduce(:+).split(':')

    seed_lines, *map_arrays = *number_strings.map do |number_string|
      number_string
        .match(/\d.*\d/m)[0]
        .split("\n")
        .map { |s| s.split.map { |num| Integer(num) } }
    end

    seeds = seed_lines[0]

    maps = map_arrays.map do |map_array|
      ranges = map_array.map do |map_line|
        destination, source, length = map_line
        MapRange.new(destination:, source:, length:)
      end

      Map.new(ranges:)
    end

    Almanac.new(seeds:, maps:)
  end

  def lowest_location_for_seeds
    seeds.map { |seed| location_for_seed(seed) }.min
  end

  def location_for_seed(seed)
    value = seed

    maps.each do |map|
      value = map.corresponding_for(value)
    end

    value
  end
end

def process(content)
  almanac = Almanac.from_lines(content)

  puts "Part 1: #{almanac.lowest_location_for_seeds}"

  puts "Part 2: #{nil.inspect}"
end

process(content)
