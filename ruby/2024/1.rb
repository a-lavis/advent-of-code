# frozen_string_literal: true

require_relative '2024'

lines = CLI.file_lines(1)

# ----------------------------------------------------------------------------
# Part 1 - total distance

colA, colB = lines.map do |line|
  line.split(' ').compact.map(&:to_i)
end.transpose.map(&:sort)

part1 = colA.zip(colB).sum { |a, b| (a - b).abs }

puts "Part 1 (total distance): #{part1}"

# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Part 2 - similarity score

part2 = colA.sum do |a|
  a * (colB.count { |b| b == a })
end

puts "Part 2 (similarity score): #{part2}"

# ----------------------------------------------------------------------------

