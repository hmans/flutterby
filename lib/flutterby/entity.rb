module Flutterby
  class Entity
    attr_accessor :parent
    attr_reader :name, :ext, :filters, :fs_path, :data, :children

    def initialize(name, parent: nil, fs_path: nil)
      @data    = {}
      reset_children!

      # Extract name, extension, and filters from given name
      parts = name.split(".")
      @name = parts.shift
      @ext  = parts.shift
      @filters = parts.reverse

      self.parent = parent

      # If a filesystem path was given, read the entity from disk
      if fs_path
        @fs_path = ::File.expand_path(fs_path)
        read
      end
    end

    def reset_children!
      @children = []
      me = self

      # Inject some extra methods into this array because this is dirty old Ruby
      @children.define_singleton_method(:<<) do |c|
        c.parent = me
        super(c)
      end

      @children.define_singleton_method(:find_by_name) do |name|
        name = name.split('.').first
        find { |c| c.name == name }
      end
    end

    def path
      parent ? ::File.join(parent.path, full_name) : full_name
    end

    # Returns all children that will compile to a HTML page.
    #
    def pages
      children.select { |c| c.ext == "html" }
    end

    def reload!
      reset_children!
      read
    end

    def list(indent: 0)
      puts "#{"   " * indent}[#{self.class}] #{path}"
    end

    def export(out_path)
      if should_publish?
        out_path = full_path(out_path)
        puts "* #{@name}: #{out_path}"
        write_static(out_path)
      end
    end

    def url
      @url ||= ::File.join(parent ? parent.url : "/", full_name)
    end

    def full_path(base)
      ::File.expand_path(::File.join(base, full_name))
    end

    def root
      parent ? parent.root : self
    end

    def to_s
      "<#{self.class} #{self.path}>"
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

    def sibling(name)
      parent && parent.find(name)
    end

    def full_name
      @full_name ||= [name, ext].compact.join(".")
    end

    def read
    end

    def write_static(path)
    end

    def should_publish?
      !name.start_with?("_")
    end

    def page?
      false
    end
  end
end
