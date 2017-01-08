module Flutterby
  class Folder < Entity
    def read
      Dir[::File.join(fs_path, "*")].each do |entry|
        if entity = Flutterby.from(entry)
          children << entity
        end
      end
    end

    def write_static(into:)
      path = full_fs_path(base: into)
      Dir.mkdir(path) unless ::File.exists?(path)

      children.each do |child|
        child.export(into: path)
      end
    end
  end
end
