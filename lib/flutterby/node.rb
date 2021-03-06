require 'flutterby/node/tree'
require 'flutterby/node/deletion'
require 'flutterby/node/reading'
require 'flutterby/node/event_handling'
require 'flutterby/node/staging'
require 'flutterby/node/rendering'
require 'flutterby/node/url'

module Flutterby
  class Node
    attr_accessor :name, :ext
    attr_reader :filters, :fs_path, :prefix, :slug, :timestamp

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

      logger.debug "Created node #{internal_path.colorize(:green)}"
    end

    private def clear!
      @data     = nil
      @data_proxy = nil
      @prefix   = nil
      @slug     = nil
    end

    prepend Tree
    prepend Deletion
    prepend Reading
    prepend EventHandling
    prepend Staging
    prepend Rendering
    prepend Url


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
      "<#{self.class} #{internal_path}>"
    end

    def full_name
      [name, ext].compact.join(".")
    end

    def mime_type
      (ext && MIME::Types.type_for(ext).first) || MIME::Types["text/plain"].first
    end

    def file?
      !folder? && should_publish?
    end

    def page?
      file? && ext == "html"
    end

    def should_publish?
      (!name.start_with?("_") && !deleted?) && (parent ? parent.should_publish? : true)
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
