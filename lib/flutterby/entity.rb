module Flutterby
  class Entity
    attr_accessor :parent, :ext
    attr_reader :name, :filters, :fs_path, :data, :children
    alias_method :folder, :parent

    def initialize(name, parent: nil, fs_path: nil)
      @parent  = parent
      @data    = {}
      reset_children!

      # Extract name, extension, and filters from given name
      parts    = name.split(".")
      @name    = parts.shift
      @filters = parts.reverse

      # We're assuming the extension is the name of the final filter
      # that will be applied. This may not be always correct, since filters
      # can also change a file's extension.
      #
      @ext     = @filters.last

      # If a filesystem path was given, read the entity from disk
      if fs_path
        @fs_path = ::File.expand_path(fs_path)
        read
      end
    end

    #
    # Children
    #

    def reset_children!
      @children = []
      me = self

      # Inject some extra methods into this array because this is dirty old Ruby
      @children.define_singleton_method(:<<) do |c|
        c.parent = me
        super(c)
      end

      @children.define_singleton_method(:find_by_name) do |name|
        # Look for a fully qualified name (index.html), or a simple name (index)?
        if name.include?(".")
          find { |c| c.full_name == name }
        else
          find { |c| c.name == name }
        end
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
        child = @children.find_by_name($1)
        $'.empty? ? child : child.find($')
      end
    end

    # Walk the tree up, invoking the passed block for every entity
    # found on the way, passing the entity as its only argument.
    #
    def walk_up(val = nil, &blk)
      val = blk.call(self, val)
      parent ? parent.walk_up(val, &blk) : val
    end

    # Walk the graph from the root to this entity. Just like walk_up,
    # except the block will be called on higher level entities first.
    #
    def walk_down(val = nil, &blk)
      val = parent ? parent.walk_up(val, &blk) : val
      blk.call(self, val)
    end


    #
    # Reading from filesystem
    #

    def reload!
      reset_children!
      read
    end

    def read
    end


    #
    # Exporting
    #

    def export(into:)
      if should_publish?
        puts "* #{url}"
        write_static(into: into)
      end
    end

    def write_static(into:)
    end

    def should_publish?
      !name.start_with?("_")
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

    def page?
      false
    end
  end
end
