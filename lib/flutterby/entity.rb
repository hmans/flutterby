module Flutterby
  class Entity
    attr_reader :path

    def initialize(name, parent:)
      @name = name
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
