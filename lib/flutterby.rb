module Flutterby
  class Processor
    attr_reader :path

    def initialize(path)
      @path = ::File.expand_path(path)
      puts "Importing from #{@path}"

      @root = Folder.new("/", parent: self)
    end

    def export(path)
      out_path = ::File.expand_path(path)
      puts "Exporting to #{out_path}"
      @root.export(path)
    end
  end

  class Entity
    attr_reader :path

    def initialize(name, parent:)
      @name = name
      @parent = parent
      @path = ::File.join(parent.path, name)
      read
    end

    def export(path_base)
      puts "* #{@name}: #{full_path(path_base)}"
    end

    private

    def full_path(base)
      ::File.expand_path(::File.join(base, @name))
    end

    def read
    end
  end

  class Folder < Entity
    def read
      @children = read_children
    end

    def export(path_base)
      super

      @children.each do |child|
        child.export(full_path(path_base))
      end
    end

    private

    def read_children
      Dir[@path + "*"].map do |item|
        Flutterby::File.new(::File.basename(item), parent: self)
      end.compact
    end
  end

  class File < Entity
  end
end


Flutterby::Processor
  .new("./in/")
  .export("./out/")
