# frozen_string_literal: true

require_relative '2023'

class C
  CONDITIONS = [
    OPERATIONAL = '.',
    DAMAGED = '#'
  ].freeze

  UNKNOWN = '?'

  @@permutation = {}

  def self.permutation(num)
    @@permutation[num] ||= CONDITIONS.repeated_permutation(num)
  end
end

SpringRow = Data.define(:conditions, :damaged_counts) do
  def self.from_line(line)
    conditions_string, damaged_counts_string = line.strip.split

    conditions = conditions_string

    damaged_counts = damaged_counts_string.split(',').map { |s| Integer(s) }

    SpringRow.new(conditions:, damaged_counts:)
  end

  def unfold
    new_conditions = ([conditions] * 5).join('?')
    new_damaged_counts = damaged_counts * 5

    SpringRow.new(
      conditions: new_conditions,
      damaged_counts: new_damaged_counts
    )
  end

  def valid_permutation_count
    C.permutation(conditions.count(C::UNKNOWN))
     .count do |permutation|
      damaged_counts == permutation
                        .then { |p| permutation_to_conditions(p) }
                        .join
                        .split('.')
                        .reject { |s| s == '' }
                        .map(&:length)
    end
  end

  def permutation_to_conditions(permutation)
    permutation_index = -1

    conditions.chars.map do |condition|
      if condition == C::UNKNOWN
        permutation_index += 1
        permutation[permutation_index]
      else
        condition
      end
    end
  end
end

spring_rows = CLI.file_lines(12).map { |line| SpringRow.from_line(line) }

puts "Part 1: #{spring_rows.sum(&:valid_permutation_count)}"

puts "Part 2: TODO!"

# unfolded = spring_rows.map(&:unfold)

# puts "Part 2: #{unfolded.sum(&:valid_permutation_count)}"
