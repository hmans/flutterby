module Flutterby
  class Entity
    attr_reader :path
    attr_reader :name
    attr_reader :extensions

    def initialize(name, parent:)
      parts = name.split(".")
      @name = parts.first(2).join(".")
      @extensions = Array(parts[2..-1])
      @parent = parent
      @path = ::File.join(parent.path, name)
      read
      process
    end

    def export(path_base)
      if should_publish?
        out_path = full_path(path_base)
        puts "* #{@name}: #{out_path}"
        write(out_path)
      end
    end

    private

    def full_path(base)
      ::File.expand_path(::File.join(base, @name))
    end

    def read
    end

    def process
    end

    def write(path)
    end

    def should_publish?
      !name.start_with?("_")
    end
  end
end
