module Flutterby
  module Staging
    def stage!
      # First of all, we want to make sure all initializers
      # (`_init.rb` files) are executed, starting at the top of the tree.
      #
      TreeWalker.walk_tree(self) do |node|
        if node.full_name == "_init.rb"
          node.parent.load_initializer!(node)
        end
      end

      # In a second pass, walk the tree to invoke any available
      # setup methods.
      #
      TreeWalker.walk_tree(self) do |node|
        node.emit(:created)
      end
    end

    # Extend all of this node's siblings. See {#extend_all}.
    #
    def extend_siblings(*mods, &blk)
      extend_all(siblings, *mods, &blk)
    end

    # Extend this node's parent. See {#extend_all}.
    #
    def extend_parent(*mods, &blk)
      extend_all([parent], *mods, &blk)
    end

    # Extend all of the specified `nodes` with the specified module(s). If
    # a block is given, the nodes will be extended with the code found
    # in the block.
    #
    def extend_all(nodes, *mods, &blk)
      if block_given?
        mods << Module.new(&blk)
      end

      Array(nodes).each do |n|
        n.extend(*mods)
      end
    end


    protected def load_initializer!(initializer)
      logger.info "Executing initializer #{initializer.internal_path}"
      instance_eval(initializer.render)
    end
  end
end
