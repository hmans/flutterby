module Flutterby
  module Filters
    def apply!(file)
      body = file.source

      # Apply all filters
      file.filters.each do |filter|
        meth = "process_#{filter}"

        if Filters.respond_to?(meth)
          body = Filters.send(meth, body, file)
        end
      end

      file.body = body
    end

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
