module Flutterby
  # Methods related to the emitting and handling of events.
  #
  module EventHandling
    extend ActiveSupport::Concern

    included do
      attr_reader :event_handlers
    end

    # Emits a new event from this node. Emitting an event will make it
    # travel up the tree, starting with this node and ending with the tree's root
    # note, invoking the corresponding handlers on each node (including the one that
    # generated the event.)
    #
    # @param [Symbol] evt The event to emit. Can be any symbol.
    # @param args Any extra arguments to be attached to the event. These will be passed back into event handlers.
    #
    # @example Basic invocation
    #   node.emit(:foo)
    #
    # @example Emitting an event with extra arguments
    #   node.emit(:foo, name: "John")
    #
    def emit(evt, *args)
      logger.debug "#{self} emitting event '#{evt}' with #{args.inspect}"

      TreeWalker.walk_up(self) do |node|
        node.handle(evt, self, *args)
      end
    end

    # @!visibility private
    def respond_to?(meth, *args)
      super || (meth =~ %r{\Ahandle_(.+)\Z} && can_handle?($1))
    end

    # Handle an incoming event. This will dispatch to a handle_* method if
    # it's available.
    #
    def handle(evt, node, *args)
      meth = "handle_#{evt}"
      send(meth, node, *args) if respond_to?(meth)
    end

    # Register an event handler.
    #
    # @param [Symbol] evts The event -- or array of events -- that should trigger this handler.
    # @param [String|Node|Proc|Regexp] selector A selector that will be
    #   matched against the node that emitted the event. If given, the
    #   handler will only be executed if the selector matches. If {selector}
    #   is a String, it matches if it equals the node's path. If it is a
    #   Regexp, it matches when it matches against the node's path.
    #   If it is a Proc, the proc will be executed (with the originating node)
    #   as its only argument), and the handler will be executed if the proc
    #   returns true.
    #   If selector is a {Node} instance, it matches if the specified node is
    #   the originating node.
    #
    def on(evts, selector = nil, &blk)
      Array(evts).map do |evt|
        evt = evt.to_sym
        @event_handlers[evt] ||= []
        @event_handlers[evt] << { selector: selector, blk: blk }
      end
    end

    private

    def method_missing(meth, *args, &blk)
      if meth =~ %r{\Ahandle_(.+)\Z} && can_handle?($1)
        execute_event_handlers($1, *args)
      else
        super
      end
    end

    def execute_event_handlers(evt, node, *args)
      event_handlers_for(evt).each do |handler|
        if node.event_handler_applies?(handler)
          handler[:blk].call(node, *args)
        end
      end
    end

    protected def event_handler_applies?(handler)
      selector = handler[:selector]

      case selector
      when nil    then true
      when String then url == selector
      when Regexp then url =~ selector
      when Node   then self == selector
      when Proc   then selector.call(self)
      end
    end

    def can_handle?(evt)
      !!event_handlers_for(evt)
    end

    def event_handlers_for(evt)
      @event_handlers[evt.to_sym]
    end
  end
end
