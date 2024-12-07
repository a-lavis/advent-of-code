# frozen_string_literal: true

require_relative '2024'

content = CLI.get_content(5)

# ----------------------------------------------------------------------------
# Part 1 -

page_ordering_rules, page_number_updates = content.split("\n\n").map do |section|
  section.split("\n")
end

page_ordering_rules = page_ordering_rules.map { _1.split('|').map(&:to_i) }
page_number_updates = page_number_updates.map { _1.split(',').map(&:to_i) }

after_to_before_index = page_ordering_rules.reduce({}) do |index, (before, after)|
  {
    **index,
    after => Set[ *index[after], before ]
  }
end

sorted_updates = page_number_updates.group_by do |update|
  update.each_with_index.all? do |before, i|
    next true unless should_be_befores = after_to_before_index[before]

    afters = update.slice((i+1)..)

    !should_be_befores.intersect?(afters)
  end
end

correct_updates = sorted_updates[true]

def sum_middle_numbers(updates)
  updates.sum do |update|
    update[(update.length - 1) / 2]
  end
end

part_1 = sum_middle_numbers(correct_updates)

puts "Part 1 (): #{part_1}"

# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Part 2 -

incorrect_updates = sorted_updates[false]

corrected_updates = incorrect_updates.map do |update|
  update.sort do |a, b|
    if after_to_before_index[b]&.include?(a) # a before b
      -1
    elsif after_to_before_index[a]&.include?(b) # b before a
      1
    else
      0
    end
  end
end

part_2 = sum_middle_numbers(corrected_updates)

puts "Part 2 (): #{part_2}"

# ----------------------------------------------------------------------------
