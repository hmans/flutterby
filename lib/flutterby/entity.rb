module Flutterby
  class Entity
    attr_reader :name, :ext, :extensions, :parent, :path

    def initialize(name, parent: nil, prefix: nil)
      parts = name.split(".")
      @name = parts.shift
      @ext  = parts.shift
      @extensions = parts
      @parent = parent
      @prefix = prefix
      @path = ::File.expand_path(::File.join(parent ? parent.full_path : @prefix, name))
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

    def full_path(base = nil)
      base ||= parent ? parent.full_path : @prefix
      ::File.expand_path(::File.join(base, full_name))
    end

    def call(env)
      ['200', {"Content-Type" => "text/html"}, [name]]
    end

    private

    def sibling(name)
      parent && parent.find(name)
    end

    def full_name
      @full_name ||= [name, ext].compact.join(".")
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
