module Flutterby
  class Layout
    def initialize(view)
      @view = view
    end

    def apply!
      @view._body = collect_layouts.inject(@view._body) do |output, layout|
        tilt = Flutterby::Filters.tilt(layout.ext, layout.source)
        tilt.render(@view) { output }.html_safe
      end
    end

    class << self
      def apply!(view)
        new(view).apply!
      end
    end

    private

    def collect_layouts
      layouts = []

      # Collect layouts explicitly configured for node
      if defined? @view.node.layout
        Array(@view.node.layout).each do |sel|
          # If a false is explicity specified, that's all the layouts
          # we're expected to render
          return layouts if sel == false

          if layout = @view.node.find(sel)
            layouts << layout
          else
            raise "No layout found for path expression '#{sel}'"
          end
        end
      end

      # Decide on a starting node for walking the tree upwards
      start = layouts.any? ? layouts.last.parent : @view.node

      # Walk the tree up, collecting any layout files found on our way
      TreeWalker.walk_up(start) do |node|
        if layout = node.sibling("_layout")
          layouts << layout
        end
      end

      layouts
    end
  end
end
