require 'benchmark'

module Flutterby
  class Node
    attr_accessor :parent, :ext, :source, :body
    attr_reader :name, :filters, :fs_path, :data, :children

    def initialize(name, parent: nil, fs_path: nil)
      @parent  = parent
      @data    = {}

      # Extract name, extension, and filters from given name
      parts    = name.split(".")
      @name    = parts.shift
      @filters = parts.reverse

      # We're assuming the extension is the name of the final filter
      # that will be applied. This may not be always correct, since filters
      # can also change a file's extension.
      #
      @ext     = @filters.last

      # If a filesystem path was given, read the node from disk
      if fs_path
        @fs_path = ::File.expand_path(fs_path)
      end

      reload!
    end

    #
    # Children
    #

    def reset_children!
      @children = []
    end

    def add_child(node)
      node.parent = self
      children << node
    end

    def find_child(name)
      if name.include?(".")
        @children.find { |c| c.full_name == name }
      else
        @children.find { |c| c.name == name }
      end
    end

    def tree_size
      children.inject(children.length) do |count, child|
        count + child.tree_size
      end
    end

    # Returns all children that will compile to a HTML page.
    #
    def pages
      children.select { |c| c.ext == "html" }
    end

    #
    # Path Algebra
    #

    def path
      parent ? ::File.join(parent.path, full_name) : full_name
    end

    def url
      ::File.join(parent ? parent.url : "/", full_name)
    end

    def full_fs_path(base:)
      ::File.expand_path(::File.join(base, full_name))
    end


    #
    # Tree Walking
    #

    def root
      parent ? parent.root : self
    end

    def root?
      root == self
    end

    def sibling(name)
      parent && parent.find(name)
    end

    def find(path)
      return self if path.nil? || path.empty?

      # remove duplicate slashes
      path.gsub!(%r{//}, "/")

      case path
      when %r{^\.\./?} then
        parent ? parent.find($') : nil
      when %r{^\.} then
        self
      when %r{^/} then
        root.find($')
      when %r{^([^/]+)/?} then
        child = find_child($1)
        $'.empty? ? child : child.find($')
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

    #
    # Reading from filesystem
    #

    def reload!
      @body = nil
      reset_children!

      # Load contents from filesystem
      #
      if @fs_path
        if ::File.directory?(fs_path)
          Dir[::File.join(fs_path, "*")].each do |entry|
            if node = Flutterby.from(entry, parent: self)
              add_child(node)
            end
          end
        else
          @source = ::File.read(fs_path)

          # Extract date from name
          if name =~ %r{^(\d\d\d\d\-\d\d?\-\d\d?)\-}
            @data['date'] = Time.parse($1)
          end

          # Read remaining data from frontmatter. Data in frontmatter
          # will always have precedence!
          @data.merge! parse_frontmatter

          # Do some extra processing depending on extension
          meth = "read_#{ext}"
          send(meth) if respond_to?(meth)
        end
      end

      # If this node is the root node, perform some preprocessing
      if root?
        preprocess!
      end
    end

    def preprocess!
      walk_tree do |node|
        node.render_body! if node.should_preprocess?
      end
    end

    def should_preprocess?
      should_publish? && !folder? &&
        (["json", "yaml", "rb"] & filters).any?
    end

    #
    # Rendering
    #

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
      render_body! if @body.nil?
      @body
    end

    def render(layout: true)
      (layout && apply_layout?) ? apply_layout(body) : body
    end

    def apply_layout(input)
      walk_up(input) do |e, current|
        if layout = e.sibling("_layout")
          tilt = Tilt[layout.ext].new { layout.source }
          tilt.render(view) { current }
        else
          current
        end
      end
    end

    def apply_layout?
      page?
    end



    #
    # Exporting
    #

    def export(into:)
      if should_publish?
        time = Benchmark.realtime do
          write_static(into: into)
        end

        logger.info "Exported #{url}"
      end
    end

    def write_static(into:)
      if folder?
        # write children, acting as a directory

        path = full_fs_path(base: into)
        Dir.mkdir(path) unless ::File.exists?(path)

        children.each do |child|
          child.export(into: path)
        end
      else
        # write a file
        ::File.write(full_fs_path(base: into), render)
      end
    end

    def should_publish?
      !name.start_with?("_")
    end


    #
    # Front Matter Parsing
    #

    def parse_frontmatter
      data = {}

      # YAML Front Matter
      if @source.sub!(/\A\-\-\-\n(.+)\n\-\-\-\n/m, "")
        data.merge! YAML.load($1)
      end

      # TOML Front Matter
      if @source.sub!(/\A\+\+\+\n(.+)\n\+\+\+\n/m, "")
        data.merge! TOML.parse($1)
      end

      data
    end

    def read_json
      data.merge!(JSON.parse(body))
    end

    def read_yaml
      data.merge!(YAML.load(body))
    end


    #
    # Misc
    #

    def to_s
      "<#{self.class} #{self.path}>"
    end

    def full_name
      [name, ext].compact.join(".")
    end

    def folder?
      children.any?
    end

    def page?
      !folder? && ext == "html"
    end

    def logger
      Flutterby.logger
    end
  end
end
