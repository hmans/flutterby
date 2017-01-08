require 'slodown'
require 'sass'
require 'tilt'
require 'slim'
require 'toml'
require 'mime-types'
require 'json'

module Flutterby
  class File < Entity
    attr_accessor :source, :body

    def reload!
      @body = nil
      super
    end

    def read
      @source = ::File.read(fs_path)

      # Extract date from name
      if name =~ %r{^(\d\d\d\d\-\d\d?\-\d\d?)\-}
        @data['date'] = Time.parse($1)
      end

      # Read remaining data from frontmatter. Data in frontmatter
      # will always have precedence!
      @data.merge! parse_frontmatter

      # Do some extra processing depending on extension
      meth = "read_#{ext}"
      send(meth) if respond_to?(meth)
    end

    def parse_frontmatter
      data = {}

      # YAML Front Matter
      if @source.sub!(/\A\-\-\-\n(.+)\n\-\-\-\n/m, "")
        data.merge! YAML.load($1)
      end

      # TOML Front Matter
      if @source.sub!(/\A\+\+\+\n(.+)\n\+\+\+\n/m, "")
        data.merge! TOML.parse($1)
      end

      data
    end

    def body
      Filters.apply!(self) if @body.nil?
      @body
    end

    def page?
      ext == "html"
    end

    def view
      @view ||= View.for(self)
    end

    def read_json
      data.merge!(JSON.parse(@source))
    end

    def read_yaml
      data.merge!(YAML.load(@source))
    end

    def apply_layout(input)
      walk_up(input) do |e, current|
        if layout = e.sibling("_layout")
          tilt = Tilt[layout.ext].new { layout.source }
          tilt.render(view) { current }
        else
          current
        end
      end
    end

    def apply_layout?
      page?
    end

    def render(layout: true)
      (layout && apply_layout?) ? apply_layout(body) : body
    end

    def write_static(path)
      ::File.write(path, render)
    end
  end
end
