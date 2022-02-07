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

  def build_tree(current, original = current)
    current = sorter(current) if current == original
    @root = Node.new(nil) if current.empty?
    return if current.length < 2

    @root = current[current.length / 2]
    left = halver(current, true)
    right = halver(current, false)
    root_setter(left, right)
    build_tree(left, original)
    build_tree(right, original)
    @root = current[current.length / 2]
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

  def insert(value, current = @root, root = @root)
    node = find(value)
    return nil if node

    current = current.data > value ? current.left : current.right
    return root.data > value ? root.left = Node.new(value) : root.right = Node.new(value) if current.nil?

    insert(value, current, current)
  end

  def delete(value, current = @root, root = @root)
    node = find(value)
    return nil unless node

    current = if current.data > value
                current.left
              elsif current.data < value
                current.right
              else
                current
              end
    if current.data == value
      if root.data > value
        return root.left = nil if current.left.nil? && current.right.nil?
        return root.left = current.left || current.right if current.left.nil? || current.right.nil?

        current = current.left
        current = current.right until current.right.nil?
        data = current.data
        delete(data)
        return root.left.data = data
      elsif root.data < value
        return root.right = nil if current.left.nil? && current.right.nil?
        return root.right = current.left || current.right if current.left.nil? || current.right.nil?

        current = current.left
        current = current.right until current.right.nil?
        data = current.data
        delete(data)
        return root.right.data = data
      else
        return root = nil if current.left.nil? && current.right.nil?
        return root = current.left || current.right if current.left.nil? || current.right.nil?

        current = current.left
        current = current.right until current.right.nil?
        data = current.data
        delete(data)
        return root.data = data
      end
    end

    delete(value, current, current)
  end

  def level_order(queue = Queue.new.push(@root), values = [], &block)
    return if queue.empty?

    current = queue.shift
    block.call(current) if block_given?
    queue << current.left if current.left
    queue << current.right if current.right
    values << current.data

    level_order(queue, values, &block)
    values unless block_given?
  end

  def preorder(values = [], current = @root, &block)
    return if current.nil?

    block.call(current) if block_given?
    values << current.data
    preorder(values, current.left, &block)
    preorder(values, current.right, &block)
    values unless block_given?
  end

  def inorder(values = [], root = @root, &block)
    return if root.nil?

    inorder(values, root.left, &block)
    block.call(root) if block_given?
    values << root.data
    inorder(values, root.right, &block)
    values unless block_given?
  end

  def postorder(values = [], root = @root, &block)
    return if root.nil?

    postorder(values, root.left, &block)
    postorder(values, root.right, &block)
    block.call(root) if block_given?
    values << root.data
    values unless block_given?
  end

  def balanced?
    leaf_values = []
    level_order { |node| leaf_values << node.data if node.left.nil? || node.right.nil? }
    depths = leaf_values.map { |value| depth(value) }
    first = depths[0]
    depths.none? { |depth| (first - depth).abs > 1 }
  end

  def rebalance
    build_tree(inorder)
  end
end

tree = Tree.new
tree.build_tree(Array.new(15) { rand(1..100) })
tree.pretty
p tree.balanced?
p tree.level_order
p tree.preorder
p tree.inorder
p tree.postorder
5.times { tree.insert(rand(100..200)) }
tree.rebalance unless tree.balanced?
tree.pretty
p tree.balanced?
p tree.level_order
p tree.preorder
p tree.inorder
p tree.postorder
