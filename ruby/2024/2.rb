# frozen_string_literal: true

require_relative '2024'

lines = CLI.file_lines(2)

# ----------------------------------------------------------------------------
# Part 1 - safe report count

def is_report_safe?(report)
  first, second = report

  direction = (first < second) ? :increasing : :decreasing

  report.each_cons(2).all? do |a, b|
    difference = (direction == :increasing) ? (b - a) : (a - b)

    1 <= difference && difference <= 3
  end
end

reports = lines.map { |line| line.split(' ').map(&:to_i) }
part1 = reports.count { |report| is_report_safe?(report) }

puts "Part 1 (safe report count): #{part1}"

# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Part 2 - problem dampener

def is_report_safe_with_problem_dampener?(report)
  return true if is_report_safe?(report)

  (0...(report.length)).any? do |i|
    is_report_safe?(
      [
        *report.slice(...i), *report.slice((i+1)..)
      ]
    )
  end
end

part2 = reports.count do |report|
  is_report_safe_with_problem_dampener?(report)
end

puts "Part 2 (problem dampener): #{part2}"

# ----------------------------------------------------------------------------

