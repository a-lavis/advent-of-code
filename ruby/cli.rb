# frozen_string_literal: true

# Shared CLI functionality
module CLI
  def self.get_file(day)
    argv = ARGV

    raise 'I need at least one argument' if argv.empty?
    raise 'I only take up to two arguments' if argv.length > 2

    type = argv[0]

    raise 'First argument must be either `example` or `input`' unless %w[
      example input
    ].include?(type)

    suffix = argv[1]
    suffix = "-#{suffix}" if suffix

    *repo_path_directories, _ = __dir__.split('/')

    repo_path = repo_path_directories.join('/')

    filename = "#{repo_path}/#{type}s/#{YEAR}/#{day}#{suffix}.txt"
    raise "File does not exist: #{filename}" unless File.exist?(filename)

    File.open(filename)
  end

  def self.file_lines(...)
    file = get_file(...)

    lines = file.readlines
    file.close

    lines
  end

  def self.get_content(...)
    file = get_file(...)

    content = file.read
    file.close

    content
  end
end
