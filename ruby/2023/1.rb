# frozen_string_literal: true

require_relative '2023'

STRING_TO_DIGIT = {
  'one' => '1',
  'two' => '2',
  'three' => '3',
  'four' => '4',
  'five' => '5',
  'six' => '6',
  'seven' => '7',
  'eight' => '8',
  'nine' => '9',
  '1' => '1',
  '2' => '2',
  '3' => '3',
  '4' => '4',
  '5' => '5',
  '6' => '6',
  '7' => '7',
  '8' => '8',
  '9' => '9'
}.freeze

DIGIT_REGEX = /#{STRING_TO_DIGIT.keys.join('|')}/

def get_calibration_value(stringy)
  digits = []
  while (index = stringy.index DIGIT_REGEX)
    digits << stringy.match(DIGIT_REGEX)[0]
    stringy = stringy[index + 1, stringy.length - 1]
  end

  STRING_TO_DIGIT.fetch(digits[0]) + STRING_TO_DIGIT.fetch(digits[-1])
end

part2 = CLI.file_lines(1)
           .map { |s| get_calibration_value(s) }
           .map { |s| Integer(s) }
           .sum

puts "Part 2: #{part2}"
