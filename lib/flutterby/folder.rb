module Flutterby
  class Folder < Entity
    attr_reader :children

    def list(indent: 0)
      super
      children.each { |c| c.list(indent: indent + 1) }
    end

    def read
      @children = Dir[::File.join(fs_path, "*")].map do |entry|
        Flutterby.from(entry, parent: self)
      end.compact
    end

    def write_static(path)
      Dir.mkdir(path) unless ::File.exists?(path)

      @children.each do |child|
        child.export(path)
      end
    end

    def find(name)
      name = name.split('.').first
      @children.find { |c| c.name == name }
    end

    # Returns all children that will compile to a HTML page.
    #
    def pages
      children.select { |c| c.ext == "html" }
    end



    def serve(parts, req, res)
      # If no further parts are requested, let's look for an index
      # document and serve that instead.
      if child = find(parts.empty? ? "index" : parts.shift)
        child.serve(parts, req, res)
      else
        res.headers["Content-Type"] = "text/html"
        res.body = ["404"]
      end
    end
  end
end
