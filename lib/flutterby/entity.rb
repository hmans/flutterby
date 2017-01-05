module Flutterby
  class Entity
    attr_reader :name, :ext, :filters, :parent, :fs_path, :path, :data

    def initialize(name, parent: nil, fs_path: nil)
      @parent  = parent
      @data    = {}

      # Extract date from name
      name.gsub! %r{^(\d\d\d\d\-\d\d?\-\d\d?)\-} do
        @data['date'] = Date.parse($1)
        ""
      end

      # Extract name, extension, and filters from given name
      parts = name.split(".")
      @name = parts.shift
      @ext  = parts.shift
      @filters = parts

      # Calculate full path
      @path = parent ? ::File.join(parent.path, full_name) : full_name

      # If a filesystem path was given, read the entity from disk
      if fs_path
        @fs_path = ::File.expand_path(fs_path)
        read
      end
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

    def process
    end

    def url
      @url ||= ::File.join(parent ? parent.url : "/", full_name)
    end

    def full_path(base)
      ::File.expand_path(::File.join(base, full_name))
    end

    def call(env)
      ['200', {"Content-Type" => "text/html"}, [name]]
    end

    def root
      parent ? parent.root : self
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
