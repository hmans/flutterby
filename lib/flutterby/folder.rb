module Flutterby
  class Folder < Entity
    attr_reader :children

    def read
      puts "Reading directory: #{path}"

      @children = Dir[::File.join(path, "*")].map do |item|
        name = ::File.basename(item)
        puts item
        if ::File.directory?(item)
          Flutterby::Folder.new(name, parent: self)
        else
          Flutterby::File.new(name, parent: self)
        end
      end.compact
    end

    def write(path)
      Dir.mkdir(path) unless ::File.exists?(path)

      @children.each do |child|
        child.export(path)
      end
    end

    def find(name)
      @children.find { |c| c.name == name }
    end

    # Returns all children that will compile to a HTML page.
    #
    def pages
      children.select { |c| c.ext == "html" }
    end
  end
end
