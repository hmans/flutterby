module Flutterby
  # NodeExtension is a subclass of Module that also provides a convenient
  # `setup` method for quick creation of initialization code. It's used
  # to wrap the blocks of code passed to {Node#extend_all} and friends,
  # but can also be used directly through `NodeExtension.new { ... }`.
  #
  class NodeExtension < Module
    def initialize(*args)
      @_handlers = {}
      super
    end

    def extended(base)
      if @_handlers.any?
        @_handlers.each do |evt, handlers|
          base._handlers[evt] ||= []
          base._handlers[evt].append(*handlers)
        end
      end
    end

    def on_setup(&blk)
      on(:setup, &blk)
    end

    def on(evt, &blk)
      evt = evt.to_sym
      @_handlers[evt] ||= []
      @_handlers[evt] << blk
    end
  end
end
