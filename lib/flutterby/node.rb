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

    private def clear!
      @data     = nil
      @data_proxy = nil
      @prefix   = nil
      @slug     = nil
    end

    module Paths
      # Returns the node's URL.
      #
      def url
        deleted? ? nil : ::File.join(parent ? parent.url : "/", full_name)
      end
    end

    prepend Paths


    require 'flutterby/node/tree'
    prepend Tree


    require 'flutterby/node/deletion'
    prepend Deletion


    require 'flutterby/node/reading'
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
