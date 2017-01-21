require 'benchmark'

module Flutterby
  class Node
    attr_accessor :name, :ext, :source
    attr_writer :body
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
    end

    concerning :Paths do
      def path
        parent ? ::File.join(parent.path, full_name) : full_name
      end

      def url
        ::File.join(parent ? parent.url : "/", full_name)
      end

      def full_fs_path(base:)
        ::File.expand_path(::File.join(base, full_name))
      end
    end

    concerning :Tree do
      def root
        parent ? parent.root : self
      end

      def root?
        root == self
      end

      def sibling(name)
        parent && parent.find(name)
      end

      def siblings
        parent && parent.children
      end

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

      # Walk the tree up, invoking the passed block for every node
      # found on the way, passing the node as its only argument.
      #
      def walk_up(val = nil, &blk)
        val = blk.call(self, val)
        parent ? parent.walk_up(val, &blk) : val
      end

      # Walk the graph from the root to this node. Just like walk_up,
      # except the block will be called on higher level nodes first.
      #
      def walk_down(val = nil, &blk)
        val = parent ? parent.walk_up(val, &blk) : val
        blk.call(self, val)
      end

      # Walk the entire tree, top to bottom.
      #
      def walk_tree(val = nil, &blk)
        val = blk.call(self, val)
        children.each do |child|
          val = child.walk_tree(val, &blk)
        end

        val
      end
    end

    concerning :Reading do
      def reload!
        @body     = nil
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

    concerning :Data do
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
        parse_frontmatter!

        # Do some extra processing depending on extension
        meth = "read_#{ext}!"
        send(meth) if respond_to?(meth)
      end

      def parse_frontmatter!
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
        @data.merge!(JSON.parse(body))
      end

      def read_yaml!
        @data.merge!(YAML.load(body))
      end

      def read_yml!
        read_yaml!
      end

      def read_toml!
        @data.merge!(TOML.parse(body))
      end
    end

    concerning :Staging do
      def stage!
        # First of all, we want to make sure all nodes have their
        # available extensions loaded.
        #
        walk_tree do |node|
          node.load_extension! unless node.name == "_node"
        end

        # Now do another pass, prerendering stuff where necessary,
        # extracting data, registering URLs to be exported, etc.
        #
        walk_tree do |node|
          node.render_body! if node.should_prerender?
        end
      end

      def load_extension!
        if extension = sibling("_node.rb")
          instance_eval(extension.body)
        end
      end

      def should_prerender?
        !folder? &&
          (["json", "yml", "yaml", "rb", "toml"] & filters).any?
      end
    end


    concerning :Rendering do
      def view
        @view ||= View.for(self)
      end

      def render_body!
        time = Benchmark.realtime do
          Filters.apply!(self)
        end

        logger.info "Rendered #{url} in #{sprintf "%.1f", time * 1000}ms"
      end

      def body
        if @body.nil?
          data   # make sure data is lazy-loaded
          render_body!
        end

        @body
      end

      def render(opts = {})
        layout = opts[:layout]
        view.opts.merge!(opts)
        (layout && apply_layout?) ? apply_layout(body) : body
      end

      def apply_layout(input)
        walk_up(input) do |node, current|
          if layout = node.sibling("_layout")
            tilt = Flutterby::Filters.tilt(layout.ext, layout.source)
            tilt.render(view) { current }.html_safe
          else
            current
          end
        end
      end

      def apply_layout?
        page?
      end
    end





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
      !folder?
    end

    def page?
      !folder? && ext == "html" && should_publish?
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
