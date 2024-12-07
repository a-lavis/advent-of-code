# frozen_string_literal: true

require_relative '2024'

content = CLI.get_content(3)

# ----------------------------------------------------------------------------
# Part 1 - 


class Parser
  DIGITS = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0].map(&:to_s).freeze

  attr_reader :results

  def initialize(chars, do_and_dont)
    @chars = chars
    @enabled = true
    @mode = :nothing
    @first_operand = +""
    @second_operand = +""
    @results = []
    @do_and_dont = do_and_dont
  end

  def parse!
    @chars.each { |char| parse_char!(char) }
  end

  def parse_char!(char)
    case @mode
    when :nothing
      case char
      when 'm'
        @mode = :m if @enabled
      when 'd'
        @mode = :d
      else
        clear!
      end
    when :m
      case char
      when 'u'
        @mode = :u
      else
        clear!
      end
    when :u
      case char
      when 'l'
        @mode = :l
      else
        clear!
      end
    when :l
      case char
      when '('
        @mode = :open_paren
      else
        clear!
      end
    when :open_paren
      case char
      when *DIGITS
        @mode = :first_operand
        @first_operand << char
      else
        clear!
      end
    when :first_operand
      case char
      when *DIGITS
        @first_operand << char
      when ','
        @mode = :comma
      else
        clear!
      end
    when :comma
      case char
      when *DIGITS
        @mode = :second_operand
        @second_operand << char
      else
        clear!
      end
    when :second_operand
      case char
      when *DIGITS
        @second_operand << char
      when ')'
        @results << [@first_operand, @second_operand]
        clear!
      else
        clear!
      end
    when :d
      case char
      when 'o'
        @mode = :o if @do_and_dont
      else
        clear!
      end
    when :o
      case char
      when '('
        @mode = :do_open_paren
      when 'n'
        @mode = :n
      else
        clear!
      end
    when :do_open_paren
      case char
      when ')'
        @enabled = true
        clear!
      else
        clear!
      end
    when :n
      case char
      when "'"
        @mode = :apostrophe
      else
        clear!
      end
    when :apostrophe
      case char
      when 't'
        @mode = :t
      else
        clear!
      end
    when :t
      case char
      when '('
        @mode = :dont_open_paren
      else
        clear!
      end
    when :dont_open_paren
      case char
      when ')'
        @enabled = false
        clear!
      else 
        clear!
      end
    end
  end

  def clear!
    @mode = :nothing
    @first_operand = +""
    @second_operand = +""
  end
end

chars = content.split('')

part_1_parser = Parser.new(chars, false)
part_1_parser.parse!

part_1 = part_1_parser.results.sum { |a, b| a.to_i * b.to_i }

puts "Part 1 (): #{part_1}"

# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Part 2 - 

part_2_parser = Parser.new(chars, true)
part_2_parser.parse!

part_2 = part_2_parser.results.sum { |a, b| a.to_i * b.to_i }

puts "Part 2 (): #{part_2}"

# ----------------------------------------------------------------------------

