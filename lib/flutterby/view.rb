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
      def for(entity)
        # create a new view instance
        view = new(entity)

        # walk the tree up to dynamically extend the view
        entity.parent.walk_up do |e|
          e.extend_view!(view)
        end

        # return the finished view object
        view
      end
    end
  end
end
