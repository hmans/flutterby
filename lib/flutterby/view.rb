module Flutterby
  class View
    attr_reader :node, :opts
    alias_method :page, :node

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

    class << self
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
