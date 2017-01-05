require 'slodown'
require 'sass'
require 'tilt'
require 'slim'
require 'toml'
require 'mime-types'

module Flutterby
  class File < Entity
    attr_reader :contents

    def reload!
      @filtered_contents = nil
      super
    end

    def read
      @contents = ::File.read(fs_path)

      # Extract date from name
      if name =~ %r{^(\d\d\d\d\-\d\d?\-\d\d?)\-}
        @data['date'] = Time.parse($1)
      end

      # Read remaining data from frontmatter. Data in frontmatter
      # will always have precedence!
      @data.merge! parse_frontmatter
    end

    def parse_frontmatter
      data = {}
      @contents.sub!(/\A\-\-\-\n(.+)\n\-\-\-\n/m) do
        data.merge! YAML.load($1)
        ""
      end

      @contents.sub!(/\A\+\+\+\n(.+)\n\+\+\+\n/m) do
        data.merge! TOML.parse($1)
        ""
      end

      data
    end

    def filtered_contents
      @filtered_contents ||= begin
        result = @contents

        # Apply all filters
        filters.each do |filter|
          meth = "process_#{filter}"
          if respond_to?(meth)
            result = send(meth, result)
          else
            puts "Woops, no #{meth} available :("
          end
        end

        result
      end
    end

    def page?
      ext == "html"
    end

    def view
      @view ||= View.new(self)
    end

    def process_erb(input)
      tilt = Tilt["erb"].new { input }
      tilt.render(view)
    end

    def process_slim(input)
      tilt = Tilt["slim"].new { input }
      tilt.render(view)
    end

    def process_md(input)
      Slodown::Formatter.new(input).complete.to_s
    end

    def process_scss(input)
      engine = Sass::Engine.new(input, syntax: :scss)
      engine.render
    end

    def apply_layout(input)
      output = input

      # collect layouts to apply
      layouts = []
      current = self
      while current = current.parent
        if layout = current.find("_layout")
          layouts << layout
        end
      end

      # Apply all layouts in order
      layouts.each do |layout|
        tilt = Tilt[layout.ext].new { layout.contents }
        output = tilt.render(view) { output }
      end

      output
    end

    def apply_layout?
      page?
    end

    def render(layout: true)
      rendered = filtered_contents
      (layout && apply_layout?) ? apply_layout(rendered) : rendered
    end

    def write_static(path)
      ::File.write(path, render)
    end

    def serve(parts, req, res)
      # Determine MIME type
      mime_type = MIME::Types.type_for(ext) || "text/plain"

      # Build response
      res.headers["Content-Type"] = mime_type
      res.body = [render]
    end
  end
end
