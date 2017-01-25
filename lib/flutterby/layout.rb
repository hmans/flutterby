module Flutterby
  module Layout
    extend self

    # Determines which layouts should be applied to the view object (based on
    # the node it is rendering), and then applies each of these layouts in order,
    # modifying the view in place.
    #
    def apply!(body, view:)
      collect_layouts(view).inject(body) do |acc, layout|
        layout.render { acc }
      end
    end

    private

    def collect_layouts(view)
      layouts = []

      # Collect layouts explicitly configured for node
      if defined? view.node.layout
        Array(view.node.layout).each do |sel|
          # If a false is explicity specified, that's all the layouts
          # we're expected to render
          return layouts if sel == false

          if layout = view.node.find(sel)
            layouts << layout
          else
            raise "No layout found for path expression '#{sel}'"
          end
        end
      end

      # Decide on a starting node for walking the tree upwards
      start = layouts.any? ? layouts.last.parent : view.node

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
