# frozen_string_literal: true

# Shared CLI functionality
module CLI
  def self.file_lines
    argv = ARGV

    raise 'I need exactly one argument' if argv.length != 1

    filename = argv[0]

    raise 'First argument must be a filename of a file that exists' unless File.exist?(filename)

    file = File.open(filename)
    content = file.readlines
    file.close

    content
  end
end
