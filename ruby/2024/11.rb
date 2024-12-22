# frozen_string_literal: true

require 'benchmark'

require_relative '2024'

content = CLI.get_content(11)

# ----------------------------------------------------------------------------
# Part 1 -

part_1 = content

def blink(stone)
  return [1] if stone == 0

  string = stone.to_s
  string_size = string.size

  return [stone * 2024] unless string_size.even?

  halfway = string_size / 2

  [
    string[...halfway].to_i,
    string[halfway..].to_i
  ]
end

stones = content.split(' ').map do |string|
  string.to_i
end

part_1 = 0

puts (Benchmark.measure do
  25.times do
    stones = stones.flat_map { |stone| blink(stone) }
  end

  part_1 = stones.size
end)


puts "Part 1 (): #{part_1}"

# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Part 2 -

part_2 = 0

puts (Benchmark.measure do
  50.times do
    stones = stones.flat_map { |stone| blink(stone) }
  end

  part_2 = stones.size
end)

puts "Part 2 (): #{part_2}"

# ----------------------------------------------------------------------------
