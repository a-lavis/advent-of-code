# frozen_string_literal: true

argv = ARGV

raise 'I need exactly one argument' if argv.length != 1

filename = argv[0]

raise 'First argument must be a filename of a file that exists' unless File.exist?(filename)

file = File.open(filename)
content = file.readlines
file.close

# -----------------------------------------------------------------------------
# The code for Part 2 is only performant on Ruby >= v3.3.0-preview3.
# It is not performant on Ruby <= v3.3.0-preview2.
#
# This is because of the following:
# https://github.com/ruby/ruby/commit/6ae2996e291750bab4ff59a06ba11c8d6bbe5aaa
#
# I'm not using the Range objects as enumerators, so I could just Data.define
# a simpler data structure that just stores the start and end, and then define
# a instance method called "count" that just subtracts the start from the end,
# with negative values coerced to 0. This would allow this code to be
# performant on older versions of Ruby.
# -----------------------------------------------------------------------------

MapRange = Data.define(:destination_begin, :source_begin, :length) do
  def source_end
    source_begin + length - 1
  end

  def source_range
    source_begin..source_end
  end

  def include?(given_value)
    source_range.include?(given_value)
  end

  def corresponding_for(given_value)
    delta = given_value - source_begin
    destination_begin + delta
  end

  def lower_range_for(given_range)
    given_begin = given_range.first
    given_end = given_range.last

    #  given:  |---...
    # source: |----...
    # There is no part of given less than source.
    return nil if source_begin <= given_begin

    #  given: ...---|
    # source:         |---...
    # There is no overlap between given and source.
    return given_range if given_end < source_begin

    lower_range = given_begin..source_begin
    return nil if lower_range.count.zero?

    lower_range
  end

  def upper_range_for(given_range)
    given_begin = given_range.first
    given_end = given_range.last

    #  given: ...----|
    # source: ...---|
    # There is no part of given less than source.
    return nil if given_end <= source_end

    #  given:         |---...
    # source: ...---|
    # There is no overlap between given and source.
    return given_range if source_end < given_begin

    upper_range = source_end..given_end
    return nil if upper_range.count.zero?

    upper_range
  end

  def destination_range_for(given_range)
    given_begin = given_range.first
    given_end = given_range.last

    overlap_range = ([given_begin, source_begin].max)..([given_end, source_end].min)
    return nil if overlap_range.count.zero?

    corresponding_for(overlap_range.first)..corresponding_for(overlap_range.last)
  end
end

Map = Data.define(:ranges) do
  def corresponding_for(source_value)
    range = ranges.find { |r| r.include?(source_value) }

    return source_value if range.nil?

    range.corresponding_for(source_value)
  end

  def corresponding_ranges(source_ranges)
    source_ranges.flat_map do |source_range|
      corresponding_ranges_for_source_range(source_range)
    end
  end

  def corresponding_ranges_for_source_range(original_source_range)
    ranges.reduce([[original_source_range], []]) do |map_ranges_acc, map_range|
      source_ranges, destination_ranges = map_ranges_acc

      new_source_ranges, new_destination_ranges = corresponding_ranges_for_map_range(
        source_ranges,
        map_range
      )

      [new_source_ranges, destination_ranges + new_destination_ranges]
    end.flatten(1)
  end

  def corresponding_ranges_for_map_range(source_ranges, map_range)
    source_ranges.reduce([[], []]) do |source_ranges_acc, source_range|
      upper_and_lower_ranges, destination_ranges = source_ranges_acc
      [
        upper_and_lower_ranges + [
          map_range.lower_range_for(source_range),
          map_range.upper_range_for(source_range)
        ].compact,
        destination_ranges + [
          map_range.destination_range_for(source_range)
        ].compact
      ]
    end
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
        destination_begin, source_begin, length = map_line
        MapRange.new(destination_begin:, source_begin:, length:)
      end

      Map.new(ranges:)
    end

    Almanac.new(seeds:, maps:)
  end

  def lowest_location_for_seeds
    seeds.map { |seed| location_for_seed(seed) }.min
  end

  def location_for_seed(seed)
    maps.reduce(seed) { |acc, map| map.corresponding_for(acc) }
  end

  def seed_ranges
    seeds.each_slice(2).map { |start, length| start..start + length - 1 }
  end

  def lowest_location_for_seed_ranges
    location_ranges_for_ranges(seed_ranges).map(&:first).min
  end

  def location_ranges_for_ranges(ranges)
    maps.reduce(ranges) { |acc, map| map.corresponding_ranges(acc) }
  end
end

def process(content)
  almanac = Almanac.from_lines(content)

  puts "Part 1: #{almanac.lowest_location_for_seeds}"

  puts "Part 2: #{almanac.lowest_location_for_seed_ranges}"
end

process(content)
