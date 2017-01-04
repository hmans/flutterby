require 'slodown'
require 'sass'
require 'tilt'
require 'toml'

module Flutterby
  class File < Entity
    attr_reader :contents, :data

    def read
      @contents = ::File.read(@path)
      @data = parse_frontmatter
    end

    def parse_frontmatter
      data = {}
      @contents.sub!(/\A\-\-\-\n(.+)\n\-\-\-\n/) do
        data.merge! YAML.load($1)
        ""
      end

      @contents.sub!(/\A\+\+\+\n(.+)\n\+\+\+\n/) do
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

    def process_erb
      @contents = ERB.new(@contents).result
    end

    def process_md
      @contents = Slodown::Formatter.new(@contents).complete.to_s
    end

    def process_scss
      engine = Sass::Engine.new(@contents, syntax: :scss)
      @contents = engine.render
    end

    def write(path)
      if should_publish?
        process!

        # Apply layout
        if ext == "html"
          if layout = parent.find("_layout")
            @contents = begin
              tilt = Tilt[layout.ext].new { layout.contents }
              tilt.render(self) { @contents }
            end
          end
        end

        ::File.write(path, @contents)
      end
    end
  end
end
