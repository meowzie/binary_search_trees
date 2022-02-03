# frozen_string_literal: true

require 'pry-byebug'

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

  def initialize
    @root = nil
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

  def sorter(array)
    if array.any? { |item| item.instance_of?(Integer) }
      array.sort.uniq.map { |item| Node.new(item) }
    else
      array
    end
  end

  def build_tree(array)
    array = sorter(array)
    @root = Node.new(nil) if array.empty?
    return if array.length < 2

    @root = array[array.length / 2]
    left = halver(array, true)
    right = halver(array, false)
    root_setter(left, right)
    build_tree(left)
    build_tree(right)
    @root = array[array.length / 2]
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

  def find(value, current = @root, counter = 0, should_count: false)
    return nil if current.nil? || current.data.nil?

    if value == current.data
      return counter if should_count

      return current
    end

    current = value < current.data ? current.left : current.right
    should_count ? find(value, current, counter + 1, should_count: true) : find(value, current)
  end

  def insert(value, current = @root)
    return nil if current.data == value

    if current.left.nil? && current.right.nil?
      return current.left = Node.new(value) if value < current.data

      return current.right = Node.new(value)
    end

    current = value < current.data ? current.left : current.right
    insert(value, current)
  end

  def parent_selector(node)
    parent = @root
    until parent.left == node || parent.right == node || parent == node
      parent = parent.left if node.data < parent.data
      parent = parent.right if node.data > parent.data
    end
    parent
  end

  def delete(value)
    node = find(value)
    return nil if node.nil?

    parent = parent_selector(node)
    if node.left.nil? && node.right.nil?
      return @root = Node.new(nil) if node == @root

      parent.left == node ? parent.left = nil : parent.right = nil
    elsif node.left && node.right
      child = node.right
      child = child.left until child.left.nil?
      parent = parent_selector(child)
      parent.left == child ? parent.left = nil : parent.right = nil
      node.data = child.data
    else
      child = node.left || node.right
      return @root = child if node == @root

      parent.left == node ? parent.left = child : parent.right = child
    end
  end

  def level_order(queue = Queue.new.push(@root), values = [], &block)
    return if queue.empty?

    current = queue.shift
    block.call(current.data) if block_given?
    queue << current.left if current.left
    queue << current.right if current.right
    values << current.data

    level_order(queue, values, &block)
    values unless block_given?
  end

  def preorder(values = [], current = @root, &block)
    return if current.nil?

    block.call(current.data) if block_given?
    values << current.data
    preorder(values, current.left, &block)
    preorder(values, current.right, &block)
    values unless block_given?
  end

  def inorder(values = [], root = @root, &block)
    return if root.nil?

    inorder(values, root.left, &block)
    block.call(root.data) if block_given?
    values << root.data
    inorder(values, root.right, &block)
    values unless block_given?
  end

  def postorder(values = [], root = @root, &block)
    return if root.nil?

    postorder(values, root.left, &block)
    postorder(values, root.right, &block)
    block.call(root.data) if block_given?
    values << root.data
    values unless block_given?
  end
end

array = [36, 43, 50, 59]
# 4.times { array.push(rand(100)) }
tree = Tree.new
tree.build_tree(array)
tree.pretty
binding.pry
tree.insert(32)
tree.insert(37)
tree.delete(50)
