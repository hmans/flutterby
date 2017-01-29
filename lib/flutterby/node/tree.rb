module Flutterby
  module Tree
    def self.prepended(base)
      base.send :attr_reader, :children, :parent
    end

    def clear!
      super
      @children = []
    end

    # Returns the tree's root node.
    #
    def root
      parent ? parent.root : self
    end

    # Returns true if this node is also the tree's root node.
    #
    def root?
      root == self
    end

    # Returns this node's siblings (ie. other nodes within the
    # same folder node.)
    #
    def siblings
      parent && (parent.children - [self])
    end

    # Returns the sibling with the specified name.
    #
    def sibling(name)
      parent && parent.find(name)
    end

    # Returns all of this node's descendants (ie. children and
    # their children and so on.)
    #
    def descendants
      _descendants.flatten.uniq
    end

    private def _descendants
      [children, children.map(&:descendants)]
    end

    # Returns the complete tree, including this node.
    #
    def all_nodes
      [self] + descendants
    end

    # Returns the size of the graph starting with this
    # node.
    #
    def size
      all_nodes.length
    end

    # Among this node's children, find a node by its name. If the
    # name passed as an argument includes a dot, the name will match against
    # the full name of the children; otherwise, just the base name.
    #
    # Examples:
    #
    #     # returns the first child called "index"
    #     find_child("index")
    #
    #     # returns the child called "index" with extension "html"
    #     find_child("index.html")
    #
    def find_child(name, opts = {})
      name_attr = name.include?(".") ? "full_name" : "name"

      @children.find do |c|
        (c.should_publish? || !opts[:public_only]) &&
          (c.send(name_attr) == name)
      end
    end

    def emit_child(name)
      # Override this to dynamically create child nodes.
    end

    # Move this node to a new parent. The parent can be specified as either
    # a node object, or a path expression.
    #
    def move_to(new_parent)
      self.parent = new_parent.is_a?(String) ?
        find!(new_parent) : new_parent
    end

    def parent=(new_parent)
      # Remove from previous parent
      if @parent
        @parent.children.delete(self)
      end

      # Assign new parent (it may be nil)
      @parent = new_parent

      # Notify new parent
      if @parent
        @parent.children << self
      end
    end

    # Returns all children that will compile to a HTML page.
    #
    def pages
      children.select { |c| c.page? }
    end

    # Creates a new node, using the specified arguments, as a child
    # of this node.
    #
    def create(name, **args)
      args[:parent] = self
      Node.new(name.to_s, **args)
    end

    # Like {find}, but raises an exception when the specified node could not
    # be found.
    #
    def find!(path, *args)
      find(path, *args) || raise("Could not find node for path expression '#{path}'")
    end

    # Find a node by the specified path expression.
    #
    def find(path, opts = {})
      path = path.to_s
      return self if path.empty?

      # remove duplicate slashes
      path = path.gsub(%r{/+}, "/")

      case path
      # ./foo/...
      when %r{^\./?} then
        parent ? parent.find($', opts) : root.find($', opts)

      # /foo/...
      when %r{^/} then
        root.find($', opts)

      # foo/...
      when %r{^([^/]+)/?} then
        # Use the next path part to find a child by that name.
        # If no child can't be found, try to emit a child, but
        # not if the requested name starts with an underscore.
        if child = find_child($1, opts) || (emit_child($1) unless $1.start_with?("_"))
          # Depending on the tail of the requested find expression,
          # either return the found node, or ask it to find the tail.
          $'.empty? ? child : child.find($', opts)
        end
      end
    end

    # Within this (sub-)tree, find the node that matches the file system
    # path specified in `fs_path`.
    #
    def find_for_fs_path(fs_path)
      fs_path = File.expand_path(fs_path)
      TreeWalker.walk_tree(self) do |node|
        return node if node.fs_path == fs_path
      end
    end
  end
end
