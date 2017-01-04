module Flutterby
  class Runner
    attr_reader :path

    def initialize(path)
      @path = ::File.expand_path(path)
      puts "Importing from #{@path}"

      @root = Folder.new("/", parent: self)
    end

    def process
      @root.process
      self
    end

    def export(path)
      out_path = ::File.expand_path(path)
      puts "Exporting to #{out_path}"
      @root.export(path)
      self
    end
  end
end
