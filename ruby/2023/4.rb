# frozen_string_literal: true

require_relative '2023'

Card = Struct.new(:winning_numbers, :card_numbers) do
  attr_accessor :count
  attr_reader :numbers_we_won_count

  def initialize(...)
    super
    @count = 1
    set_numbers_we_won_count
  end

  def self.from_line(stringy)
    _, body = stringy.split(':')

    winning_numbers, card_numbers = body.split('|').map do |numbers_string|
      numbers_string.strip.split.map { |s| Integer(s) }
    end

    Card.new(winning_numbers:, card_numbers:)
  end

  def points
    warn_about_duplicates
    return 0 if numbers_we_won_count.zero?

    (2**(numbers_we_won_count - 1)) * count
  end

  private

  def set_numbers_we_won_count
    numbers_we_didnt_win = winning_numbers - card_numbers
    numbers_we_won = winning_numbers - numbers_we_didnt_win

    @numbers_we_won_count = numbers_we_won.length
  end

  def warn_about_duplicates
    warn 'This card has duplicate winning numbers.' if winning_numbers.uniq != winning_numbers

    return unless card_numbers.uniq != card_numbers

    warn 'This card has duplicate card numbers.'
  end
end

cards = CLI.file_lines(4).map { |s| Card.from_line(s) }

points = cards.map(&:points).sum

puts "Part 1: #{points}"

cards.each_with_index do |card, index|
  cards[index + 1, card.numbers_we_won_count].each do |other_card|
    other_card.count += card.count
  end
end

points = cards.map(&:count).sum

puts "Part 2: #{points}"

points = cards.map(&:points).sum

puts "Bonus! Points for all scorecards: #{points}"
