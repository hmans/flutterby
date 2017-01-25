module Flutterby
  module Layout
    extend self

    # Determines which layouts should be applied to the view object (based on
    # the node it is rendering), and then applies each of these layouts in order,
    # modifying the view in place.
    #
    def apply!(body, view:)
      collect_layouts(view.node).inject(body) do |acc, layout|
        layout.render_with_view(view, extra_filters: [layout.ext]) { acc }
      end
    end

    private

    def collect_layouts(node)
      layouts = []

      # Collect layouts explicitly configured for node
      if defined? node.layout
        Array(node.layout).each do |sel|
          # If a false is explicity specified, that's all the layouts
          # we're expected to render
          return layouts if sel == false

          if layout = node.find(sel)
            layouts << layout
          else
            raise "No layout found for path expression '#{sel}'"
          end
        end
      end

      # Decide on a starting node for walking the tree upwards
      start = layouts.any? ? layouts.last.parent : node

      # Walk the tree up, collecting any layout files found on our way
      TreeWalker.walk_up(start) do |n|
        if layout = n.sibling("_layout")
          layouts << layout
        end
      end

      layouts
    end
  end
end
