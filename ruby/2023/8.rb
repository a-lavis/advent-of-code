# frozen_string_literal: true

require_relative '../cli'

NodeChildren = Data.define(:left, :right)

DesertMap = Data.define(:instructions, :network, :ghost_start_nodes) do
  def self.from_lines(lines)
    instructions_string, _, *network_strings = lines

    instructions = instructions_string.strip.chars
    instructions.freeze

    network = {}
    ghost_start_nodes = []
    network_strings.each do |line|
      node_id, node_children_string = line.split('=').map(&:strip)
      left, right = node_children_string.gsub(/ |\(|\)/, '').split(',')
      network[node_id] = NodeChildren.new(left:, right:)
      ghost_start_nodes << node_id if node_id.chars.last == 'A'
    end
    network.freeze
    ghost_start_nodes.freeze

    DesertMap.new(instructions:, network:, ghost_start_nodes:)
  end

  def calculate_instruction(instructions_index)
    instruction = instructions[instructions_index]

    if instruction.nil?
      instructions_index = 0
      instruction = instructions[instructions_index]
    end

    [instructions_index, instruction]
  end

  def traverse(node_id, instruction)
    children = network[node_id]
    case instruction
    when 'L'
      children.left
    when 'R'
      children.right
    end
  end

  def steps_to_traverse(starting_node_id)
    return 'Not applicable.' if network[starting_node_id].nil?

    node_id = starting_node_id
    count = 0
    instructions_index = 0

    until yield(node_id)
      instructions_index, instruction = calculate_instruction(instructions_index)

      node_id = traverse(node_id, instruction)

      count += 1
      instructions_index += 1
    end

    count
  end

  def brute_force_steps_to_traverse_as_ghost
    node_ids = ghost_start_nodes.dup
    count = 0
    instructions_index = 0

    until node_ids.all? { |node_id| node_id.chars.last == 'Z' }
      instructions_index, instruction = calculate_instruction(instructions_index)

      node_ids.map!.with_index do |node_id, index|
        puts "#{index}: #{node_id} (at #{count})" if node_id.chars.last == 'Z'
        traverse(node_id, instruction)
      end

      count += 1
      instructions_index += 1
    end

    count
  end

  # I figured this out by using `brute_force_steps_to_traverse_as_ghost` and
  # making a conjecture given the printed output. I don't fully understand why
  # it works though - why are the 'Z' nodes found at regular intervals?
  # I get that when traversing the network you have to cycle eventually, but
  # couldn't you reach a 'Z' node multiple times in a single cycle?
  def steps_to_traverse_as_ghost
    steps_array = ghost_start_nodes.map do |node_id|
      steps_to_traverse(node_id) do |node_id_to_check|
        node_id_to_check[-1] == 'Z'
      end
    end

    steps_array.reduce(1, :lcm)
  end
end

desert_map = DesertMap.from_lines(CLI.file_lines)

steps_to_traverse_from_aaa = desert_map.steps_to_traverse('AAA') do |node_id|
  node_id == 'ZZZ'
end

puts "Part 1: #{steps_to_traverse_from_aaa}"
puts "Part 2: #{desert_map.steps_to_traverse_as_ghost}"
