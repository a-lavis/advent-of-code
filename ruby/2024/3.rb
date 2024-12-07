# frozen_string_literal: true

require_relative '2024'

content = CLI.get_content(3)

# ----------------------------------------------------------------------------
# Part 1 -

DIGITS = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0].map(&:to_s).freeze

def clear(state)
  {
    **state,
    mode: :nothing,
    first_operand: '',
    second_operand: ''
  }
end

def parse(chars, do_and_dont)
  end_state = chars.reduce(
    enabled: true,
    mode: :nothing,
    first_operand: '',
    second_operand: '',
    result: 0
  ) do |state, char|
    state => { enabled:, mode:, first_operand:, second_operand:, result: }

    case mode
    when :nothing
      case char
      when 'm'
        enabled ? { **state, mode: :m } : clear(state)
      when 'd'
        do_and_dont ? { **state, mode: :d } : clear(state)
      else
        clear(state)
      end
    when :m
      case char
      when 'u'
        { **state, mode: :u }
      else
        clear(state)
      end
    when :u
      case char
      when 'l'
        { **state, mode: :l }
      else
        clear(state)
      end
    when :l
      case char
      when '('
        { **state, mode: :open_paren }
      else
        clear(state)
      end
    when :open_paren
      case char
      when *DIGITS
        {
          **state,
          mode: :first_operand,
          first_operand: "#{first_operand}#{char}"
        }
      else
        clear(state)
      end
    when :first_operand
      case char
      when *DIGITS
        { **state, first_operand: "#{first_operand}#{char}" }
      when ','
        { **state, mode: :comma }
      else
        clear(state)
      end
    when :comma
      case char
      when *DIGITS
        {
          **state,
          mode: :second_operand,
          second_operand: "#{second_operand}#{char}"
        }
      else
        clear(state)
      end
    when :second_operand
      case char
      when *DIGITS
        { **state, second_operand: "#{second_operand}#{char}" }
      when ')'
        {
          **state,
          result: result + (first_operand.to_i * second_operand.to_i),
          first_operand: '',
          second_operand: '',
          mode: :nothing
        }
      else
        clear(state)
      end
    when :d
      case char
      when 'o'
        { **state, mode: :o }
      else
        clear(state)
      end
    when :o
      case char
      when '('
        { **state, mode: :do_open_paren }
      when 'n'
        { **state, mode: :n }
      else
        clear(state)
      end
    when :do_open_paren
      case char
      when ')'
        {
          **state,
          enabled: true,
          first_operand: '',
          second_operand: '',
          mode: :nothing
        }
      else
        clear(state)
      end
    when :n
      case char
      when "'"
        { **state, mode: :apostrophe }
      else
        clear(state)
      end
    when :apostrophe
      case char
      when 't'
        { **state, mode: :t }
      else
        clear(state)
      end
    when :t
      case char
      when '('
        { **state, mode: :dont_open_paren }
      else
        clear(state)
      end
    when :dont_open_paren
      case char
      when ')'
        {
          **state,
          enabled: false,
          first_operand: '',
          second_operand: '',
          mode: :nothing
        }
      else
        clear(state)
      end
    end
  end

  end_state[:result]
end

chars = content.split('')

part_1 = parse(chars, false)

puts "Part 1 (): #{part_1}"

# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Part 2 -

part_2 = parse(chars, true)

puts "Part 2 (): #{part_2}"

# ----------------------------------------------------------------------------
