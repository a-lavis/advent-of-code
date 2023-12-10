# frozen_string_literal: true

require_relative '2023'

# A schematic, with methods for processing the grid data
class Schematic
  # @current_gears: Array of Gears
  Gear = Data.define(:column, :row) do
    def indices
      [column, row]
    end
  end

  def initialize(grid)
    @grid = grid.dup.freeze
    @gear_index = {}
  end

  def add_part_number_to_gear_index(part_number)
    @current_gears.each do |gear|
      column, row = gear.indices
      @gear_index[column] ||= {}
      @gear_index[column][row] ||= []
      @gear_index[column][row] << part_number
    end
  end

  def sum_gear_index
    @gear_index.values.map do |column_hash|
      column_hash.values.map do |part_numbers|
        part_numbers[0] * part_numbers[1] if part_numbers.length == 2
      end.compact.sum
    end.sum
  end

  def part_number_sum
    sum = 0

    @grid.each_with_index do |line, row|
      number_string = ''
      part_number = false
      @current_gears = []

      line.each_with_index do |char, column|
        case char
        when /\d/
          number_string += char
          part_number ||= symbol_adjacent?(column, row)
        else
          if part_number
            number = Integer(number_string)
            sum += number
            add_part_number_to_gear_index(number)
          end

          number_string = ''
          part_number = false
          @current_gears = []
        end
      end

      next unless part_number

      number = Integer(number_string)
      sum += number
      add_part_number_to_gear_index(number)
    end

    sum
  end

  def symbol_adjacent?(original_column, original_row)
    columns = (-1..1).map { |d| original_column + d }
    rows = (-1..1).map { |d| original_row + d }

    columns.each do |column|
      rows.each do |row|
        next if column == original_column && row == original_row
        next if out_of_bounds(column, row)

        case @grid[row][column]
        when /\d/, '.'
          next
        when '*'
          @current_gears << Gear.new(column:, row:)
          return true
        else
          return true
        end
      end
    end

    false
  end

  def out_of_bounds(column, row)
    min_row = 0
    max_row = @grid.length - 1
    return true if row < min_row || row > max_row

    min_column = 0
    max_column = @grid[row].length - 1
    column < min_column || column > max_column
  end
end

grid = CLI.file_lines(3).map { |line| line.chars.filter { |c| c != "\n" } }
schematic = Schematic.new(grid)

puts "Part 1: #{schematic.part_number_sum}"
puts "Part 2: #{schematic.sum_gear_index}"
