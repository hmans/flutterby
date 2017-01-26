module Flutterby
  module Layout
    extend self

    def collect_layouts(node, list: nil, include_tree: true)
      layouts = []
      list ||= node.layout

      # Collect layouts explicitly configured for node
      if defined? list
        Array(list).each do |sel|
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

      if include_tree
        # Decide on a starting node for walking the tree upwards
        start = layouts.any? ? layouts.last.parent : node

        # Walk the tree up, collecting any layout files found on our way
        TreeWalker.walk_up(start) do |n|
          if layout = n.sibling("_layout")
            layouts << layout
          end
        end
      end

      layouts
    end
  end
end
