module Flutterby
  module TreeWalker
    extend self

    # Walk the tree up, invoking the passed block for every node
    # found on the way, passing the node as its only argument.
    #
    def walk_up(node, val = nil, &blk)
      val = blk.call(node, val)
      node.parent ? walk_up(node.parent, val, &blk) : val
    end

    # Walk the graph from the root to the specified node. Just like walk_up,
    # except the block will be called on higher level nodes first.
    #
    def walk_down(node, val = nil, &blk)
      val = node.parent ? walk_up(node.parent, val, &blk) : val
      blk.call(node, val)
    end

    # Walk the entire tree, top to bottom.
    #
    def walk_tree(node, val = nil, &blk)
      val = blk.call(node, val)
      node.children.each do |child|
        val = walk_tree(child, val, &blk)
      end

      val
    end
  end
end
