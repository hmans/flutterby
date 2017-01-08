module Flutterby
  class View
    attr_reader :entity
    alias_method :page, :entity

    def initialize(entity)
      @entity = entity
    end

    def date_format(date, fmt)
      date.strftime(fmt)
    end

    def render(expr, *args)
      find(expr).render(*args)
    end

    def find(expr)
      entity.find(expr) or raise "No entity found for #{expr}"
    end

    class << self
      def for(file)
        # create a new view instance
        view = new(file)

        # walk the tree up to dynamically extend the view
        file.parent.walk_down do |e|
          if view_entity = e.find("_view.rb")
            case view_entity.ext
            when "rb" then
              view.instance_eval(view_entity.source)
            else
              raise "Unknown view extension #{view_entity.full_name}"
            end
          end
        end

        # return the finished view object
        view
      end
    end
  end
end
