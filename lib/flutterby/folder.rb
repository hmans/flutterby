module Flutterby
  class Folder < Entity
    def list(indent: 0)
      super
      children.each { |c| c.list(indent: indent + 1) }
    end

    def read
      Dir[::File.join(fs_path, "*")].each do |entry|
        children << Flutterby.from(entry)
      end
    end

    def write_static(path)
      Dir.mkdir(path) unless ::File.exists?(path)

      children.each do |child|
        child.export(path)
      end
    end
  end
end
