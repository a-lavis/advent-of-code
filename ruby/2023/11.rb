# frozen_string_literal: true

require_relative '2023'

Space = Struct.new(:image, :empty_rows, :empty_columns, :multiplier) do
  def self.from_lines(lines, multiplier)
    image = lines.map(&:strip).map(&:freeze).freeze

    empty_rows = image.each_with_index.reduce([]) do |row_acc, row_info|
      row, row_index = row_info

      if row.include?('#')
        row_acc
      else
        row_acc + [row_index]
      end
    end.freeze

    empty_columns = 0.upto(image.first.length - 1).reduce([]) do |column_acc, column_index|
      if 0.upto(image.length - 1).none? { |r| image[r][column_index] == '#' }
        column_acc + [column_index]
      else
        column_acc
      end
    end.freeze

    Space.new(image:, empty_rows:, empty_columns:, multiplier:)
  end

  def galaxies
    image.flat_map.with_index do |line, row|
      line.chars.map.with_index do |char, column|
        [row, column] if char == '#'
      end.compact
    end
  end

  def sum_of_paths
    galaxies.combination(2).map do |a, b|
      a_row, a_column = a
      b_row, b_column = b

      row_range = a_row < b_row ? a_row..b_row : b_row..a_row
      column_range = a_column < b_column ? a_column..b_column : b_column..a_column

      empty_rows_crossed = row_range.to_a.intersection(empty_rows)
      empty_columns_crossed = column_range.to_a.intersection(empty_columns)

      traversed_row_count = (a_row - b_row).abs
      traversed_column_count = (a_column - b_column).abs

      traversed_super_row_count = ((multiplier-1) * empty_rows_crossed.length)
      traversed_super_column_count = ((multiplier-1) * empty_columns_crossed.length)

      traversed_row_count + traversed_column_count + traversed_super_row_count + traversed_super_column_count
    end.sum
  end
end

space = Space.from_lines(CLI.file_lines(11), 2)

puts "Part 1: #{space.sum_of_paths}"

space.multiplier = 1_000_000

puts "Part 2: #{space.sum_of_paths}"
