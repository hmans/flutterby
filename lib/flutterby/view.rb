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
  end
end
