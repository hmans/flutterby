module Flutterby
  # A helper module with methods to walk across a node tree in various
  # directions and variations and perform a block of code on each passed node.
  #
  module TreeWalker
    extend self

    # Walk the tree up, invoking the passed block for every node
    # found on the way, passing the node as its only argument.
    #
    def walk_up(node, val = nil, &blk)
      val = blk.call(node, val)
      node.parent ? walk_up(node.parent, val, &blk) : val
    end

    # Walk the graph from the root to the specified node. Just like {#walk_up},
    # except the block will be called on higher level nodes first.
    #
    def walk_down(node, val = nil, &blk)
      val = node.parent ? walk_up(node.parent, val, &blk) : val
      blk.call(node, val)
    end

    # Walk the entire tree, top to bottom, starting with its root, and then
    # descending into its child layers.
    #
    def walk_tree(node, val = nil, &blk)
      # Build a list of nodes to run block against. Since
      # tree walking will also be used to modify the tree,
      # we can't relay on simple recursion and iteration here.
      #
      nodes = [node] + node.descendants

      # Execute block
      nodes.inject(val) do |val, n|
        blk.call(n, val)
      end
    end
  end
end
