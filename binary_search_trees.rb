# frozen_string_literal: true

# creates new items in the binary search tree
class Node
  attr_accessor :data, :right, :left

  def initialize(value)
    @data = value
    @right = nil
    @left = nil
  end
end

# creates the tree
class Tree
  attr_accessor :root, :list

  def initialize(array)
    @root = 0
    @list = array.sort.uniq.map { |value| Node.new(value) }
  end

  def pretty(node = @root, prefix = '', is_left = true)
    pretty(node.right, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.data}"
    pretty(node.left, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left
  end

  def halver(array, left_truthiness)
    case left_truthiness
    when true
      array[0...array.length / 2]
    when false
      array[array.length / 2 + 1...array.length]
    end
  end

  def root_setter(left, right)
    @root.left = left[left.length / 2] unless left[left.length / 2] == @root
    @root.right = right[right.length / 2] unless right[right.length / 2] == @root
  end

  def build_tree(array = @list)
    @root = @list[@list.length / 2]
    return if array.length < 2

    left = halver(array, true)
    right = halver(array, false)
    @root = array[array.length / 2]
    root_setter(left, right)
    @root = @list[@list.length / 2]
    build_tree(left)
    build_tree(right)
    @root.data
  end

  def depth(value)
    find(value, @root, 0, should_count: true)
  end

  def height(value, counter = 0, current_node = find(value))
    return nil if find(value).nil?
    return counter - 1 if current_node.nil?
    return counter if current_node.right.nil? && current_node.left.nil?

    # this is working properly (i.e., allowing the overall function to give the correct results
    # but right side is seems fishy; must confirm that right side is working as it should and if not, must debug
    left = height(value, counter + 1, current_node.left)
    right = height(value, counter + 1, current_node.right)
    left >= right ? left : right
  end

  def find(value, current_node = @root, counter = 0, should_count: false)
    return nil if current_node.nil?

    if value == current_node.data
      return counter if should_count

      return current_node
    end

    current_node = value < current_node.data ? current_node.left : current_node.right
    should_count ? find(value, current_node, counter + 1, should_count: true) : find(value, current_node)
  end

  def insert(value, current_node = @root)
    return nil if current_node.data == value

    if current_node.left.nil? && current_node.right.nil?
      return current_node.left = Node.new(value) if value < current_node.data

      return current_node.right = Node.new(value)
    end

    current_node = value < current_node.data ? current_node.left : current_node.right
    insert(value, current_node)
  end
end
