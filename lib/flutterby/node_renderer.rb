module Flutterby
  module NodeRenderer
    extend self

    def render(node, view, &blk)
      output = ""

      time = Benchmark.realtime do
        output = Filters.apply!(node, view: view, &blk)

        # Apply layouts
        if view.opts[:layout] && node.page?
          output = Layout.apply!(output, view: view)
        end
      end

      # Log rendering times using different colors based on duration
      color = if time > 1
        :red
      elsif time > 0.25
        :yellow
      else
        :green
      end

      logger.debug "Rendered #{node.url.colorize(:blue)} in #{sprintf("%.1fms", time * 1000).colorize(color)}"

      output
    end

    private

    def logger
      @logger ||= Flutterby.logger
    end
  end
end
