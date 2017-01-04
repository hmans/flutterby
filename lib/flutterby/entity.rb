module Flutterby
  class Entity
    attr_reader :name, :ext, :extensions, :parent, :path

    def initialize(name, parent:)
      parts = name.split(".")
      @name = parts.shift
      @ext  = parts.shift
      @extensions = parts
      @parent = parent
      @path = ::File.join(parent.path, name)
      read
    end

    def export(path_base)
      if should_publish?
        out_path = full_path(path_base)
        puts "* #{@name}: #{out_path}"
        write(out_path)
      end
    end

    def process
    end

    private

    def full_name
      @full_name ||= [name, ext].compact.join(".")
    end

    def full_path(base)
      ::File.expand_path(::File.join(base, full_name))
    end

    def read
    end

    def write(path)
    end

    def should_publish?
      !name.start_with?("_")
    end
  end
end
