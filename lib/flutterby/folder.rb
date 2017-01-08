module Flutterby
  class Folder < Entity
    def read
      Dir[::File.join(fs_path, "*")].each do |entry|
        if entity = Flutterby.from(entry)
          children << entity
        end
      end
    end

    def write_static(path)
      Dir.mkdir(path) unless ::File.exists?(path)

      children.each do |child|
        child.export(path)
      end
    end

    def extend_view!(view)
      # Load the view extension available in this folder into the given view.
      #
      if view_entity = find("_view.rb")
        case view_entity.ext
        when "rb" then
          view.instance_eval(view_entity.source)
        else
          raise "Unknown view extension #{view_entity.full_name}"
        end
      end

      # Then pass the whole thing up the stack.
      #
      parent ? parent.extend_view!(view) : view
    end
  end
end
