# frozen_string_literal: true

require_relative '../cli'

Sequence = Data.define(:numbers) do
  def self.from_line(line)
    Sequence.new(numbers: line.split.map { |s| Integer(s) })
  end

  def difference_sequence
    difference_numbers = numbers[0, numbers.length - 1].zip(
      numbers[1, numbers.length]
    ).map { |a, b| b - a }

    Sequence.new(numbers: difference_numbers)
  end

  def difference_sequences
    lists = []
    sequence = self

    # I wanna do recursion so bad lol... but Ruby doesn't (always) have TCO
    until sequence.numbers.all?(&:zero?)
      lists.prepend(sequence)
      sequence = sequence.difference_sequence
    end

    lists
  end

  def next_value
    difference_sequences.reduce(0) do |last_difference, sequence|
      sequence.numbers.last + last_difference
    end
  end

  def previous_value
    difference_sequences.reduce(0) do |last_difference, sequence|
      sequence.numbers.first - last_difference
    end
  end
end

sequences = CLI.file_lines.map { |line| Sequence.from_line(line) }
puts "Part 1: #{sequences.map(&:next_value).sum}"
puts "Part 2: #{sequences.map(&:previous_value).sum}"
