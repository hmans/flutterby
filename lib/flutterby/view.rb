module Flutterby
  class View
    attr_reader :node
    alias_method :page, :node

    def initialize(node)
      @node = node
    end

    def date_format(date, fmt)
      date.strftime(fmt)
    end

    def render(expr, *args)
      find(expr).render(*args)
    end

    def find(expr)
      node.find(expr) or raise "No node found for #{expr}"
    end

    class << self
      def for(file)
        # create a new view instance
        view = new(file)

        # walk the tree up to dynamically extend the view
        file.parent.walk_down do |e|
          if view_node = e.find("_view.rb")
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
