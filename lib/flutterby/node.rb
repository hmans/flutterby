require 'benchmark'

module Flutterby
  class Node
    attr_accessor :name, :ext, :source
    attr_reader :filters, :parent, :fs_path, :children

    def initialize(name, parent: nil, fs_path: nil, source: nil)
      @fs_path = fs_path ? ::File.expand_path(fs_path) : nil
      @source  = source

      # Extract name, extension, and filters from given name
      parts    = name.split(".")
      @name    = parts.shift
      @ext     = parts.shift
      @filters = parts.reverse

      # Register this node with its parent
      if parent
        self.parent = parent
      end

      reload!
      extract_data!
    end

    module Paths
      # Returns the node's URL.
      #
      def url
        ::File.join(parent ? parent.url : "/", full_name)
      end
    end

    include Paths


    module Tree
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

      def sibling(name)
        parent && parent.find(name)
      end

      # Returns this node's siblings (ie. other nodes within the
      # same folder node.)
      #
      def siblings
        parent && (parent.children - [self])
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
      def find_child(name)
        if name.include?(".")
          @children.find { |c| c.full_name == name }
        else
          @children.find { |c| c.name == name }
        end
      end

      def emit_child(name)
        # Override this to dynamically create child nodes.
      end

      def tree_size
        children.inject(children.length) do |count, child|
          count + child.tree_size
        end
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

      def find(path)
        path = path.to_s
        return self if path.empty?

        # remove duplicate slashes
        path = path.gsub(%r{/+}, "/")

        case path
        when %r{^\./?} then
          parent ? parent.find($') : root.find($')
        when %r{^/} then
          root.find($')
        when %r{^([^/]+)/?} then
          # Use the next path part to find a child by that name.
          # If no child can't be found, try to emit a child, but
          # not if the requested name starts with an underscore.
          if child = find_child($1) || (emit_child($1) unless $1.start_with?("_"))
            # Depending on the tail of the requested find expression,
            # either return the found node, or ask it to find the tail.
            $'.empty? ? child : child.find($')
          end
        end
      end
    end

    include Tree


    module Reading
      def reload!
        @data     = nil
        @children = []

        load_from_filesystem! if @fs_path
      end

      def load_from_filesystem!
        if @fs_path
          if ::File.directory?(fs_path)
            Dir[::File.join(fs_path, "*")].each do |entry|
              name = ::File.basename(entry)
              Flutterby::Node.new(name, parent: self, fs_path: entry)
            end
          else
            @source = ::File.read(fs_path)
          end
        end
      end
    end

    include Reading


    module Data
      def data
        extract_data! if @data.nil?
        @data
      end

      def extract_data!
        @data ||= {}.with_indifferent_access

        # Extract date from name
        if name =~ %r{^(\d\d\d\d\-\d\d?\-\d\d?)\-}
          @data['date'] = Date.parse($1)
        end

        # Read remaining data from frontmatter. Data in frontmatter
        # will always have precedence!
        extract_frontmatter!

        # Do some extra processing depending on extension. This essentially
        # means that your .json etc. files will be rendered at least once at
        # bootup.
        meth = "read_#{ext}!"
        send(meth) if respond_to?(meth)
      end

      def extract_frontmatter!
        @data || {}

        if @source
          # YAML Front Matter
          if @source.sub!(/\A\-\-\-\n(.+)\n\-\-\-\n/m, "")
            @data.merge! YAML.load($1)
          end

          # TOML Front Matter
          if @source.sub!(/\A\+\+\+\n(.+)\n\+\+\+\n/m, "")
            @data.merge! TOML.parse($1)
          end
        end
      end

      def read_json!
        @data.merge!(JSON.parse(render))
      end

      def read_yaml!
        @data.merge!(YAML.load(render))
      end

      def read_yml!
        read_yaml!
      end

      def read_toml!
        @data.merge!(TOML.parse(render))
      end
    end

    include Data



    module Staging
      def stage!
        # First of all, we want to make sure all initializers
        # (`_init.rb` files) are executed, starting at the top of the tree.
        #
        TreeWalker.walk_tree(self) do |node|
          if node.full_name == "_init.rb"
            logger.debug "Executing initializer #{node.url}"
            node.instance_eval(node.render)
          end
        end

        # In a second pass, walk the tree to invoke any available
        # setup methods.
        #
        TreeWalker.walk_tree(self) do |node|
          node.setup
        end
      end

      # Override this method in any node that requires specific setup.
      def setup
      end

      # Extend all of this node's siblings with the specified module(s). If
      # a block is given, the siblings will be extended with the code found
      # in the block.
      #
      def extend_siblings(*mods, &blk)
        if block_given?
          mods << Module.new(&blk)
        end

        siblings.each do |n|
          n.extend(*mods)
        end
      end

      def extend_parent(*mods, &blk)
        if block_given?
          mods << Module.new(&blk)
        end

        parent.extend(*mods)
      end
    end

    include Staging


    module Rendering
      def view(opts = {})
        View.for(self, opts)
      end

      def render(opts = {})
        view(opts).render!
      end
    end

    include Rendering




    #
    # Misc
    #

    def to_s
      "<#{self.class} #{self.url}>"
    end

    def full_name
      [name, ext].compact.join(".")
    end

    def folder?
      children.any?
    end

    def file?
      !folder? && should_publish?
    end

    def page?
      file? && ext == "html"
    end

    def should_publish?
      !name.start_with?("_")
    end

    def logger
      Flutterby.logger
    end

    def copy(new_name, data = {})
      dup.tap do |c|
        c.name = new_name
        c.data.merge!(data)
        parent.children << c
      end
    end
  end
end
