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
    end
  end

  class Folder
    attr_reader :path

    def initialize(name, parent:)
      @name = name
      @parent = parent
      @path = ::File.join(parent.path, name)
      @children = read_children
    end

    def export(path)
      puts @children.inspect
    end

    private

    def read_children
      Dir[@path + "*"].map do |item|
        Flutterby::File.new(item, parent: self)
      end.compact
    end
  end

  class File
    def initialize(name, parent:)
      @full_path = ::File.join(parent.path, name)
      puts @full_path
    end
  end
end


Flutterby::Processor
  .new("./in/")
  .export("./out/")
