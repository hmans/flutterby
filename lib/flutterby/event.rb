module Flutterby
  # An Event instance wraps an event emitted by nodes through {Node#emit}.
  # It will always be passed back into event handlers as their first argument.
  #
  class Event
    attr_reader :name, :time, :args
    attr_accessor :source
    alias_method :node, :source

    def initialize(name, source: nil, args: {})
      @name = name.to_sym
      @source = source
      @args = args
      @time = Time.now
    end

    def to_sym
      name
    end

    def ==(o)
      name == o.to_sym
    end
  end
end
