# frozen_string_literal: true

require '../cli'

Race = Data.define(:time, :distance_record) do
  def win?(speed)
    distance_record < (speed * (time - speed))
  end

  def ways_to_lose_half_count
    (1..((time - 1) / 2)).reduce(0) do |sum, speed|
      return sum if win?(speed)

      sum + 1
    end
  end

  def ways_to_lose
    wtl = ways_to_lose_half_count * 2

    return wtl if time.odd?
    # if time - 1 is odd

    return wtl unless wtl == time - 2
    # if we found (time - 1) - 1) ways to to lose

    return wtl if win?(time / 2)

    # if the middle speed doesn't beat the record

    # add another loss
    wtl + 1
  end

  def ways_to_win_count
    (time - 1) - ways_to_lose
  end
end

BoatDocument = Data.define(:races) do
  def self.from_lines(lines)
    times, distance_records = lines.map do |line|
      _, numbers_string = line.split(':')
      numbers_string.split.map { |s| Integer(s) }
    end

    races = times.zip(distance_records).map do |time, distance_record|
      Race.new(time:, distance_record:)
    end

    BoatDocument.new(races:)
  end

  def product_of_ways_to_win_counts
    races.map(&:ways_to_win_count).reduce(:*)
  end
end

lines = CLI.file_lines

boat_document = BoatDocument.from_lines(lines)

puts "Part 1: #{boat_document.product_of_ways_to_win_counts}"

time, distance_record = lines.map do |line|
  _, numbers_string = line.split(':')
  Integer(numbers_string.split.join)
end

unkerned_race = Race.new(time:, distance_record:)

puts "Part 2: #{unkerned_race.ways_to_win_count}"
