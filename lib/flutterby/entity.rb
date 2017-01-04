module Flutterby
  class Entity
    attr_reader :path
    attr_reader :name
    attr_reader :extensions

    def initialize(name, parent:)
      parts = name.split(".")
      @name = parts.first(2).join(".")
      @extensions = parts[2..-1]
      @parent = parent
      @path = ::File.join(parent.path, name)
      read
    end

    def export(path_base)
      out_path = full_path(path_base)
      puts "* #{@name}: #{out_path}"
      write(out_path)
    end

    private

    def full_path(base)
      ::File.expand_path(::File.join(base, @name))
    end

    def read
    end

    def write(path)
    end
  end
end
