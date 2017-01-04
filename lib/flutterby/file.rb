require 'slodown'
require 'sass'
require 'tilt'
require 'toml'

module Flutterby
  class File < Entity
    attr_reader :contents, :data

    def read
      @contents = ::File.read(path)
      @data = parse_frontmatter
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

    def process!
      # Apply processors
      while ext = extensions.pop do
        meth = "process_#{ext}"
        if respond_to?(meth)
          send(meth)
        else
          puts "Woops, no #{meth} available :("
        end
      end
    end

    def page?
      ext == "html"
    end

    def process_erb
      tilt = Tilt["erb"].new { @contents }
      @contents = tilt.render(self)
    end

    def process_md
      @contents = Slodown::Formatter.new(@contents).complete.to_s
    end

    def process_scss
      engine = Sass::Engine.new(@contents, syntax: :scss)
      @contents = engine.render
    end

    def apply_layout
      output = @contents

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
        output = tilt.render(self) { output }
      end

      output
    end

    def apply_layout?
      page?
    end

    def write(path)
      if should_publish?
        process!
        output = apply_layout? ? apply_layout : @contents

        ::File.write(path, output)
      end
    end
  end
end
