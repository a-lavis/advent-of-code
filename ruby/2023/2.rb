# frozen_string_literal: true

argv = ARGV

raise 'I need exactly one argument' if argv.length != 1

filename = argv[0]

raise 'First argument must be a filename of a file that exists' unless File.exist?(filename)

file = File.open(filename)
content = file.readlines
file.close

Round = Data.define(:red_count, :green_count, :blue_count) do
  def self.from_string(stringy)
    red_count = 0
    green_count = 0
    blue_count = 0

    stringy.split(',').each do |color_string|
      count = Integer(color_string.match(/\d+/)[0])
      color = color_string.match(/red|green|blue/)[0]
      case color
      when 'red'
        red_count += count
      when 'green'
        green_count += count
      when 'blue'
        blue_count += count
      else
        raise "Invalid color: #{color}"
      end
    end

    Round.new(red_count:, green_count:, blue_count:)
  end

  def possible?
    (red_count <= 12) && (green_count <= 13) && (blue_count <= 14)
  end
end

Game = Data.define(:id, :rounds) do
  def self.from_line(line)
    game_string, rounds_string = line.split(':')

    Game.new(
      id: Integer(game_string.match(/\d+/)[0]),
      rounds: rounds_string.split(';').map { |s| Round.from_string(s) }
    )
  end

  # Would this game have been possible if the bag contained only:
  #  - 12 red cubes
  #  - 13 green cubes
  #  - and 14 blue cubes
  # ?
  def possible?
    rounds.all?(&:possible?)
  end

  def power_of_minimum_set
    greatest_red = rounds.map(&:red_count).max
    greatest_green = rounds.map(&:green_count).max
    greatest_blue = rounds.map(&:blue_count).max

    greatest_red * greatest_green * greatest_blue
  end
end

def process(content)
  games = content.map { |s| Game.from_line(s) }

  part_one = games
             .filter(&:possible?)
             .map(&:id)
             .sum

  puts "Part One: #{part_one}"

  part_two = games
             .map(&:power_of_minimum_set)
             .sum

  puts "Part One: #{part_two}"
end

process(content)
