module Flutterby
  class Processor
    attr_reader :contents
    
    def initialize(source)
      @contents = source
    end

    def process
      @contents
    end
  end
end
