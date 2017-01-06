module Flutterby
  class Folder < Entity
    attr_reader :children

    def list(indent: 0)
      super
      children.each { |c| c.list(indent: indent + 1) }
    end

    def read
      @children = Dir[::File.join(fs_path, "*")].map do |entry|
        Flutterby.from(entry, parent: self)
      end.compact
    end

    def write_static(path)
      Dir.mkdir(path) unless ::File.exists?(path)

      @children.each do |child|
        child.export(path)
      end
    end

    def find(path)
      (name, slash, rest) = path.partition("/")

      name = name.split('.').first
      child = @children.find { |c| c.name == name }
      rest.empty? ? child : child.find(rest)
    end

    # Returns all children that will compile to a HTML page.
    #
    def pages
      children.select { |c| c.ext == "html" }
    end
  end
end
