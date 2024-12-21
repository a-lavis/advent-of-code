# frozen_string_literal: true

require_relative '2024'

content = CLI.get_content(9)
chars = content.chars
chars = chars.take(chars.size - 1)

# ----------------------------------------------------------------------------
# Part 1 -

filesystem = chars.each_with_index.flat_map do |x, i|
  Array.new(x.to_i, i.even? ? (i/2) : nil)
end

filesystem_part_1 = filesystem.dup

while true
  break unless (first_nil = filesystem_part_1.find_index(&:nil?))

  next unless (last = filesystem_part_1.pop)

  filesystem_part_1[first_nil] = last
end

def checksum(filesystem)
  filesystem.each_with_index.sum do |block, i|
    block ? (i * block) : 0
  end
end

part_1 = checksum(filesystem_part_1)

puts "Part 1 (): #{part_1}"

# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Part 2 -

chars.each_with_index.reduce(files: [], spaces: []) do |acc, (x, i)|
  count = x.to_i
  i.even? ?
    { **acc, files: [*acc[:files], count] } :
    { **acc, spaces: [*acc[:spaces], count] }
end => {files:, spaces:}

FILE_LENGTH = files.length

spaces = spaces.take(FILE_LENGTH - 1)

MyFile = Data.define(:count, :id)
files = files.each_with_index.map { |count, i| MyFile.new(count, i) }

def format_filesystem(files, spaces)
  return

  puts files.zip(spaces).flat_map do |file, space_count|
    [*Array.new(file.count, file.id), *(
      Array.new(space_count, '.') if space_count
    )]
  end.join
end

format_filesystem(files, spaces)

file_index = files.length - 1
while true
  break if file_index < 0

  file = files[file_index]
  block_count = file.count
  if (
    result = spaces.each_with_index.find do |space_count, i|
      break if i >= file_index
      block_count <= space_count
    end
  )
    result => [valid_space_count, valid_space_count_index]

    spaces[valid_space_count_index] = valid_space_count - block_count
    spaces[file_index - 1] += block_count + (spaces[file_index] ? spaces[file_index] : 0)
    spaces.delete_at(file_index)
    spaces.insert(valid_space_count_index, 0)
    files.delete_at(file_index)
    files.insert(valid_space_count_index+1, file)

    format_filesystem(files, spaces)
  else
    file_index -= 1
  end
end

system_index = 0
part_2 = (0...files.length).sum do |file_index|
  file = files[file_index]
  blank_count = spaces[file_index]

  file_result = file.count.times.sum do
    block_result = file.id * system_index
    system_index += 1
    block_result
  end

  system_index += blank_count if blank_count

  file_result
end

puts "Part 2 (): #{part_2}"

# ----------------------------------------------------------------------------
