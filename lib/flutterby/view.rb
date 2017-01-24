require 'benchmark'

module Flutterby
  class View
    attr_reader :node, :opts, :source
    attr_accessor :_body
    alias_method :page, :node

    # Include ERB::Util from ActiveSupport. This will provide
    # html_escape, h, and json_escape helpers.
    #
    # http://api.rubyonrails.org/classes/ERB/Util.html
    #
    include ERB::Util

    def initialize(node, opts = {})
      @node = node
      @opts = opts
      @source = node.source
      @_body = nil
    end

    def render!
      time = Benchmark.realtime do
        Filters.apply!(self)

        # Apply layouts
        if opts[:layout] && node.page?
          @_body = apply_layout!(@_body)
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

      @_body
    end

    def apply_layout!(input)
      collect_layouts.inject(input) do |output, layout|
        tilt = Flutterby::Filters.tilt(layout.ext, layout.source)
        tilt.render(self) { output }.html_safe
      end
    end

    def collect_layouts
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
      TreeWalker.walk_up(start) do |node|
        if layout = node.sibling("_layout")
          layouts << layout
        end
      end

      layouts
    end

    def to_s
      @_body ||= render!
    end

    def date_format(date, fmt)
      date.strftime(fmt)
    end

    def raw(str)
      str.html_safe
    end

    def render(expr, *args)
      if expr.is_a?(Node)
        expr.render(*args)
      else
        find(expr).render(*args)
      end
    end

    def find(*args)
      node.find(*args) or raise "No node found for #{args}"
    end

    def siblings(*args)
      node.siblings(*args)
    end

    def tag(name, attributes = {})
      ActiveSupport::SafeBuffer.new.tap do |output|
        attributes_str = attributes.keys.sort.map do |k|
          %{#{h k}="#{h attributes[k]}"}
        end.join(" ")

        opening_tag = "#{h name.downcase} #{attributes_str}".strip
        output << "<#{opening_tag}>".html_safe
        output << yield if block_given?
        output << "</#{h name}>".html_safe
      end
    end

    def link_to(text, target, attrs = {})
      href = case target
      when Flutterby::Node then target.url
      else target.to_s
      end

      tag(:a, attrs.merge(href: href)) { text }
    end

    def debug(obj)
      tag(:pre, class: "debug") { h obj.to_yaml }
    end

    def extend_view(*mods, &blk)
      if block_given?
        mods << Module.new(&blk)
      end

      extend(*mods)
    end

    def logger
      @logger ||= Flutterby.logger
    end

    class << self
      # Factory method that returns a newly created view for the given node.
      # It also makes sure all available _view.rb extensions are loaded.
      #
      def for(node, *args)
        # create a new view instance
        view = new(node, *args)

        # walk the tree up to dynamically extend the view
        TreeWalker.walk_down(node) do |e|
          if view_node = e.sibling("_view.rb")
            case view_node.ext
            when "rb" then
              view.instance_eval(view_node.source)
            else
              raise "Unknown view extension #{view_node.full_name}"
            end
          end
        end

        # return the finished view object
        view
      end
    end
  end
end
