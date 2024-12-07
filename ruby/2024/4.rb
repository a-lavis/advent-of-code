# frozen_string_literal: true

require_relative '2024'

lines = CLI.file_lines(4)

# ----------------------------------------------------------------------------
# Part 1 -

MAS = 'MAS'.chars.freeze
NEGATIVE_1_TO_1 = (-1..1).freeze

def count_xmas(lines)
  lines.each_with_index.sum do |line, y|
    line.chars.each_with_index.sum do |char, x|
      next 0 unless char == 'X'

      NEGATIVE_1_TO_1.sum do |dy|
        NEGATIVE_1_TO_1.count do |dx|
          MAS.reduce(x:, y:) do |coords, char|
            coords => { x: old_x, y: old_y }

            new_y = old_y + dy
            break unless new_y >= 0 && search_line = lines[new_y]

            new_x = old_x + dx
            break unless new_x >= 0 && search_line[new_x] == char

            { x: new_x, y: new_y }
          end
        end
      end
    end
  end
end

part_1 = count_xmas(lines)

puts "Part 1 (): #{part_1}"

# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Part 2 -

def count_mas_x(lines)
  lines.slice(1, (lines.length - 2)).each_with_index.sum do |line, top|
    line.slice(1, (line.length - 2)).chars.each_with_index.count do |char, left|
      next false unless char == 'A'

      top_line = lines[top]
      bottom_line = lines[top+2]
      right = left + 2

      case [top_line[left], top_line[right],
            bottom_line[left], bottom_line[right]]
      when ['M', 'M',
            'S', 'S']
        true
      when ['M', 'S',
            'M', 'S']
        true
      when ['S', 'M',
            'S', 'M']
        true
      when ['S', 'S',
            'M', 'M']
        true
      else
        false
      end
    end
  end
end

part_2 = count_mas_x(lines)

puts "Part 2 (): #{part_2}"

# ----------------------------------------------------------------------------
