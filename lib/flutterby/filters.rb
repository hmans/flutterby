module Flutterby
  module Filters
    def apply!(node)
      node.body = node.source

      # Apply all filters
      node.filters.each do |filter|
        meth = "process_#{filter}!"

        if Filters.respond_to?(meth)
          Filters.send(meth, node)
        end
      end
    end

    def process_rb!(node)
      node.instance_eval(node.body)
    end

    def process_erb!(node)
      node.body = tilt("erb", node.body).render(node.view)
    end

    def process_slim!(node)
      node.body = tilt("slim", node.body).render(node.view)
    end

    def process_md!(node)
      node.body = Slodown::Formatter.new(node.body).complete.to_s
    end

    def process_scss!(node)
      node.body = Sass::Engine.new(node.body, syntax: :scss).render
    end

    def tilt(format, body)
      Tilt[format].new { body }
    end

    extend self
  end
end
