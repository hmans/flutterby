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
end
