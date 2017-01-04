module Flutterby
  class Folder < Entity
    def read
      @children = read_children
    end

    def write(path)
      Dir.mkdir(path) unless ::File.exists?(path)

      @children.each do |child|
        child.export(path)
      end
    end

    def process
      @children.each(&:process)
    end

    def find(name)
      @children.find { |c| c.name == name }
    end

    private

    def read_children
      Dir[@path + "/*"].map do |item|
        name = ::File.basename(item)
        if ::File.directory?(item)
          Flutterby::Folder.new(name, parent: self)
        else
          Flutterby::File.new(name, parent: self)
        end
      end.compact
    end
  end
end
