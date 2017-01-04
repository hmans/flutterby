module Flutterby
  class View
    attr_reader :entity

    def initialize(entity)
      @entity = entity
    end

    def date_format(date, fmt)
      date.strftime(fmt)
    end
  end
end
