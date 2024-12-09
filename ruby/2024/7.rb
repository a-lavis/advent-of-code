# frozen_string_literal: true

require_relative '2024'

content = CLI.get_content(7)
lines = content.split("\n")

# ----------------------------------------------------------------------------
# Part 1 -

Equation = Data.define(:solution, :operands) do
  def self.from_line(line)
    solution, operands = line.split(':')
    Equation.new(solution.to_i, operands.split(' ').map(&:to_i))
  end

  def sub_equation
    SubEquation.new(solution, operands.drop(1), operands.first)
  end

  def valid?
    sub_equation.valid?
  end

  def valid_with_concatenation?
    sub_equation.valid_with_concatenation?
  end
end

SubEquation = Struct.new(:solution, :operands, :acc) do
  def operand = @operand ||= operands.first
  def sub_operands = @sub_operands ||= operands.drop(1)

  def sub_equation(&block)
    SubEquation.new(solution, sub_operands, block.call(acc, operand))
  end

  def valid?
    return false if solution < acc
    return solution == acc if operands.empty?

    sub_equation(&:+).valid? ||
      sub_equation(&:*).valid?
  end

  def valid_with_concatenation?
    return false if solution < acc
    return solution == acc if operands.empty?

    sub_equation(&:+).valid_with_concatenation? ||
      sub_equation(&:*).valid_with_concatenation? ||
      sub_equation { |a, b| "#{a}#{b}".to_i }.valid_with_concatenation?
  end
end

equations = lines.map { |line| Equation.from_line(line) }

part_1 = equations.filter(&:valid?).sum(&:solution)

puts "Part 1 (): #{part_1}"

# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Part 2 -

part_2 = equations.filter(&:valid_with_concatenation?).sum(&:solution)

puts "Part 2 (): #{part_2}"

# ----------------------------------------------------------------------------
