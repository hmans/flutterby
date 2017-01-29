module Flutterby
  class Node
    attr_accessor :name, :ext, :source
    attr_reader :filters, :fs_path
    attr_reader :prefix, :slug, :timestamp

    def initialize(name = nil, parent: nil, fs_path: nil, source: nil)
      raise "Either name or fs_path need to be specified." unless name || fs_path

      clear!

      @original_name = name || File.basename(fs_path)
      @fs_path = fs_path ? ::File.expand_path(fs_path) : nil
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

    prepend Paths


    def clear!
      @data     = nil
      @data_proxy = nil
      @prefix   = nil
      @slug     = nil
    end


    require 'flutterby/node/tree'
    prepend Tree


    require 'flutterby/node/deletion'
    prepend Deletion


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
        clear!
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

    prepend Reading


    require 'flutterby/node/event_handling'
    prepend EventHandling




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

    prepend Staging


    require 'flutterby/node/rendering'
    prepend Rendering




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
