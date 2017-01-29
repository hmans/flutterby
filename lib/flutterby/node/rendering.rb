module Flutterby
  module Rendering
    extend ActiveSupport::Concern
    
    # Renders the node. One of the most important methods in Flutterby, which
    # explains why it's wholly undocumented. Apologies, I'm working on it!
    #
    def render(layout: false, view: nil, extra_filters: [], locals: {}, &blk)
      # If no view was specified, create a new one for this node.
      view ||= View.for(self, locals: locals)
      layouts = []

      if layout == true
        # build standard list of layouts for rendering the full page
        layouts = Layout.collect_layouts(self, include_tree: page?)
      elsif layout
        # build list of nodes based on specified layouts
        layouts = Layout.collect_layouts(self, list: layout, include_tree: false)
      end

      # Start rendering
      output = ""
      time = Benchmark.realtime do
        # Apply filters
        output = Filters.apply! @source.html_safe,
          filters + extra_filters,
          view: view, &blk

        # Apply layouts
        output = layouts.inject(output) do |acc, layout_node|
          layout_node.render(layout: false,
            view: view, extra_filters: [layout_node.ext]) { acc }
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

      logger.debug "Rendered #{url.colorize(:blue)} in #{sprintf("%.1fms", time * 1000).colorize(color)}"

      output
    end



    # Creates a new {View} instance and uses it to
    # render this node. Returns the rendered page as a string.
    #
    # def render(opts = {}, &blk)
    #   render_with_view(View.for(self, opts), &blk)
    # end
    #
    # def render_with_view(view, *args, &blk)
    #   NodeRenderer.render(self, view, *args, &blk)
    # end
  end
end
