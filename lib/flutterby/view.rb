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

    def find(*args)
      entity.find(*args)
    end
  end
end
