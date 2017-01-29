module Flutterby
  class Node
    attr_accessor :name, :ext, :source
    attr_reader :filters, :parent, :fs_path, :children
    attr_reader :prefix, :slug, :timestamp

    def initialize(name = nil, parent: nil, fs_path: nil, source: nil)
      raise "Either name or fs_path need to be specified." unless name || fs_path

      @original_name = name || File.basename(fs_path)
      @fs_path = fs_path ? ::File.expand_path(fs_path) : nil
      @deleted = false
      @source  = source

      # Register this node with its parent
      if parent
        self.parent = parent
      end

      load!
    end

    module Paths
      # Returns the node's URL.
      #
      def url
        deleted? ? nil : ::File.join(parent ? parent.url : "/", full_name)
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

    include Tree


    module Deletion
      def deleted?
        @deleted
      end

      def delete!
        emit(:deleted)
        move_to(nil)
        @deleted = true
      end
    end

    include Deletion


    module Reading
      # Reloads the node from the filesystem, if it's a filesystem based
      # node.
      #
      def reload!
        logger.info "Reloading #{url.colorize(:blue)}"

        time = Benchmark.realtime do
          load!
          stage!
          emit(:reloaded)
        end

        logger.info "Reloaded #{url.colorize(:blue)} in #{sprintf("%.1fms", time * 1000).colorize(:light_white)}"
      end

      def data
        @data_proxy ||= Dotaccess[@data]
      end

      private

      def load!
        @data     = nil
        @data_proxy = nil
        @prefix   = nil
        @slug     = nil
        @children = []
        @timestamp = Time.now

        # Extract name, extension, and filters from given name
        parts    = @original_name.split(".")
        @name    = parts.shift
        @ext     = parts.shift
        @filters = parts.reverse

        load_from_filesystem! if @fs_path

        extract_data!
      end

      def load_from_filesystem!
        if @fs_path
          @timestamp = File.mtime(fs_path)

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

      private

      def extract_data!
        @data ||= {}.with_indifferent_access

        # Extract prefix and slug
        if name =~ %r{\A([\d-]+)-(.+)\Z}
          @prefix = $1
          @slug = $2
        else
          @slug = name
        end

        # Change this node's name to the slug. This may be made optional
        # in the future.
        @name = @slug

        # Extract date from prefix if possible
        if prefix =~ %r{\A(\d\d\d\d\-\d\d?\-\d\d?)\Z}
          @data['date'] = Date.parse($1)
        end

        # Read remaining data from frontmatter. Data in frontmatter
        # will always have precedence!
        extract_frontmatter!

        # Do some extra processing depending on extension. This essentially
        # means that your .json etc. files will be rendered at least once at
        # bootup.
        meth = "read_#{ext}!"
        send(meth) if respond_to?(meth, true)
      end

      def extract_frontmatter!
        if @source
          # YAML Front Matter
          if @source.sub!(/\A\-\-\-\n(.+?)\n\-\-\-\n/m, "")
            @data.merge! YAML.load($1)
          end

          # TOML Front Matter
          if @source.sub!(/\A\+\+\+\n(.+?)\n\+\+\+\n/m, "")
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

    include Reading


    require 'flutterby/node/event_handling'
    include EventHandling




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
        logger.info "Executing initializer #{initializer.url}"
        instance_eval(initializer.render)
      end
    end

    include Staging


    module Rendering
      # Renders the node. One of the most important methods in Flutterby, which
      # explains why it's wholly undocumented. Apologies, I'm working on it!
      #
      def render(layout: false, view: nil, extra_filters: [], locals: {}, &blk)
        # If no view was specified, create a new one for this node.
        view ||= View.for(self, locals: locals)
        layouts = []

        if layout == true
          # build standard list of layouts for rendering the full page
          layouts = Layout.collect_layouts(self, include_tree: page?)
        elsif layout
          # build list of nodes based on specified layouts
          layouts = Layout.collect_layouts(self, list: layout, include_tree: false)
        end

        # Start rendering
        output = ""
        time = Benchmark.realtime do
          # Apply filters
          output = Filters.apply! @source.html_safe,
            filters + extra_filters,
            view: view, &blk

          # Apply layouts
          output = layouts.inject(output) do |acc, layout_node|
            layout_node.render(layout: false,
              view: view, extra_filters: [layout_node.ext]) { acc }
          end
        end

        # Log rendering times using different colors based on duration
        color = if time > 1
          :red
        elsif time > 0.25
          :yellow
        else
          :green
        end

        logger.debug "Rendered #{url.colorize(:blue)} in #{sprintf("%.1fms", time * 1000).colorize(color)}"

        output
      end



      # Creates a new {View} instance and uses it to
      # render this node. Returns the rendered page as a string.
      #
      # def render(opts = {}, &blk)
      #   render_with_view(View.for(self, opts), &blk)
      # end
      #
      # def render_with_view(view, *args, &blk)
      #   NodeRenderer.render(self, view, *args, &blk)
      # end
    end

    include Rendering




    #
    # Misc
    #

    # Returns the node's title. If there is a `:title` key in {#data}, its
    # value will be used; otherwise, as a fallback, it will generate a
    # human-readable title from {#slug}.
    #
    def title
      data[:title] || slug.try(:titleize)
    end

    # Returns the layout(s) configured for this node. This is sourced from
    # the node's {data} attribute, so it can be set from front matter.
    #
    def layout
      data[:layout]
    end

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
      !name.start_with?("_") && !deleted?
    end

    def logger
      Flutterby.logger
    end

    def copy(new_name, data = {})
      full_new_name = [new_name, ext, filters.reverse].flatten.join(".")

      parent.create(full_new_name, source: source, fs_path: fs_path).tap do |node|
        node.data.merge!(data)
      end
    end
  end
end
