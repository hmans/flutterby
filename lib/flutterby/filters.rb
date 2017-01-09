module Flutterby
  module Filters
    def apply!(file)
      body = file.source

      # Apply all filters
      file.filters.each do |filter|
        meth = "process_#{filter}"

        # Set the file's extension to the requested filter. The filter
        # itself can, of course, override this (eg. the "md" filter can default
        # the extension to "html".)
        #
        file.ext = filter

        # Now apply the actual filter!
        #
        if Filters.respond_to?(meth)
          body = Filters.send(meth, body, file)
        end
      end

      file.body = body
    end

    def process_rb(input, node)
      # default the node's extension to "html"
      node.ext = "html"
      # extend the node
      mod = Module.new
      mod.class_eval(input)
      node.extend(mod)

      ""
    end

    def process_erb(input, file)
      tilt("erb", input).render(file.view)
    end

    def process_slim(input, file)
      tilt("slim", input).render(file.view)
    end

    def process_md(input, file)
      file.ext = "html"
      Slodown::Formatter.new(input).complete.to_s
    end

    def process_scss(input, file)
      Sass::Engine.new(input, syntax: :scss).render
    end

    def tilt(format, body)
      Tilt[format].new { body }
    end

    extend self
  end
end
