module Flutterby
  class Folder < Entity
    def read
      @children = read_children
    end

    def write(path)
      # TODO: make sure directory exists
      @children.each do |child|
        child.export(path)
      end
    end

    private

    def read_children
      Dir[@path + "*"].map do |item|
        Flutterby::File.new(::File.basename(item), parent: self)
      end.compact
    end
  end
end
