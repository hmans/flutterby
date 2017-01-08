module Flutterby
  module Filters
    def process_erb(input, file)
      tilt = Tilt["erb"].new { input }
      tilt.render(file.view)
    end

    def process_slim(input, file)
      tilt = Tilt["slim"].new { input }
      tilt.render(file.view)
    end

    def process_md(input, file)
      file.ext = "html"
      Slodown::Formatter.new(input).complete.to_s
    end

    def process_scss(input, file)
      engine = Sass::Engine.new(input, syntax: :scss)
      engine.render
    end

    extend self
  end
end
