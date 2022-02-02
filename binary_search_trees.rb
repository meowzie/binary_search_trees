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

  def parent_selector(value)
    greater_parent = @list.select { |node| node.left.data == value unless node.left.nil? }
    return greater_parent[0] unless greater_parent.empty?

    @list.select { |node| node.right.data == value unless node.right.nil? }[0]
  end

  def delete(value)
    node = find(value)
    return nil if node.nil?

    parent = parent_selector(node.data)
    if node.left.nil? && node.right.nil?
      @list.delete(node)
      parent.left == node ? parent.left = nil : parent.right = nil
    elsif node.left && node.right
      new_node = node.right
      new_node = new_node.left until new_node.left.nil? && new_node.right.nil?
      new_parent = parent_selector(new_node.data)
      new_parent.left == new_node ? new_parent.left = nil : new_parent.right = nil
      node.data = new_node.data
      @list.delete(new_node)
    else
      child = node.left || node.right
      @list.delete(node)
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
