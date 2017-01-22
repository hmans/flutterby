module Flutterby
  # NodeExtension is a subclass of Module that also provides a convenient
  # `setup` method for quick creation of initialization code. It's used
  # to wrap the blocks of code passed to {Node#extend_all} and friends,
  # but can also be used directly through `NodeExtension.new { ... }`.
  #
  class NodeExtension < Module
    def initialize(*args)
      @_setup_procs = []
      super
    end

    def extended(base)
      base._setup_procs.append(*@_setup_procs)
    end

    def setup(&blk)
      @_setup_procs << blk
    end
  end
end
