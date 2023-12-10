# frozen_string_literal: true

require_relative '2023'
require_relative '../cli'

module Type
  FIVE_OK = 6
  FOUR_OK = 5
  FULL_HOUSE = 4
  THREE_OK = 3
  TWO_PAIR = 2
  ONE_PAIR = 1
  HIGH_CARD = 0
end

module Card
  CARD_TYPES = [
    CA = 14,
    CK = 13,
    CQ = 12,
    CJ = 11,
    CT = 10,
    C9 = 9,
    C8 = 8,
    C7 = 7,
    C6 = 6,
    C5 = 5,
    C4 = 4,
    C3 = 3,
    C2 = 2,
    JO = 0
  ].freeze

  FROM_CHAR = {
    'A' => CA,
    'K' => CK,
    'Q' => CQ,
    'J' => CJ,
    'T' => CT,
    '9' => C9,
    '8' => C8,
    '7' => C7,
    '6' => C6,
    '5' => C5,
    '4' => C4,
    '3' => C3,
    '2' => C2
  }.freeze
end

Hand = Struct.new(:cards, :bid) do
  def self.from_line(line)
    cards_string, bid_string = line.strip.split

    cards = cards_string.chars.map { |c| Card::FROM_CHAR.fetch(c) }

    bid = Integer(bid_string)

    Hand.new(cards:, bid:)
  end

  def <=>(other)
    result = type <=> other.type

    return result unless result.zero?

    cards.zip(other.cards).map do |card, other_card|
      result = (card <=> other_card)
      return result unless result.zero?
    end

    warn "Equal hands found: #{self} and #{other}"

    0
  end

  def type
    @type ||= calculate_type
  end

  def reset_type!
    @type = nil
  end

  def jokerify!
    self.cards = cards.map { |c| c == Card::CJ ? Card::JO : c }
  end

  private

  def calculate_type
    tally = cards.tally

    joker_count = tally.delete(Card::JO)
    counts = tally.values.sort

    if joker_count
      highest_count = counts.pop || 0
      counts.push(highest_count + joker_count)
    end

    return Type::FIVE_OK if counts.include?(5)
    return Type::FOUR_OK if counts.include?(4)
    return Type::FULL_HOUSE if counts.include?(3) && counts.include?(2)
    return Type::THREE_OK if counts.include?(3)

    return Type::HIGH_CARD unless counts.include?(2)

    counts.delete_at(counts.index(2))
    return Type::ONE_PAIR unless counts.include?(2)

    Type::TWO_PAIR
  end
end

CamelCards = Struct.new(:hands) do
  def self.from_lines(lines)
    hands = lines.map { |line| Hand.from_line(line) }
    CamelCards.new(hands:)
  end

  def sort!
    hands.each(&:reset_type!)
    hands.sort!
  end

  def total_winnings
    hands.map.with_index { |hand, index| hand.bid * (index + 1) }.sum
  end

  def jokerify!
    hands.each(&:jokerify!)
  end
end

camel_cards = CamelCards.from_lines(CLI.file_lines(7))

camel_cards.sort!

puts "Part 1: #{camel_cards.total_winnings}"

camel_cards.jokerify!
camel_cards.sort!

puts "Part 2: #{camel_cards.total_winnings}"
