module Flutterby
  class View
    attr_reader :node, :opts
    alias_method :page, :node

    # Include ERB::Util from ActiveSupport. This will provide
    # html_escape, h, and json_escape helpers.
    #
    # http://api.rubyonrails.org/classes/ERB/Util.html
    #
    include ERB::Util

    def initialize(node)
      @node = node
      @opts = {}
    end

    def date_format(date, fmt)
      date.strftime(fmt)
    end

    def raw(str)
      str.html_safe
    end

    def render(expr, *args)
      find(expr).render(*args)
    end

    def find(*args)
      node.find(*args) or raise "No node found for #{args}"
    end

    def siblings(*args)
      node.siblings(*args)
    end

    def tag(name, attributes)
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

    class << self
      # Factory method that returns a newly created view for the given node.
      # It also makes sure all available _view.rb extensions are loaded.
      #
      def for(file)
        # create a new view instance
        view = new(file)

        # walk the tree up to dynamically extend the view
        file.walk_down do |e|
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
