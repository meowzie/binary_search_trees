# frozen_string_literal: true

# creates new items in the binary search tree
class Node
  def initialize(value)
    @value = value
  end
end

# creates the tree
class Tree
  def initialize
    @root = nil
  end

  def build_tree(array)
    # not yet done
    array.sort!.uniq!
  end
end
