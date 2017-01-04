require 'slodown'

module Flutterby
  class SlodownProcessor < Processor
    def process
      Slodown::Formatter.new(contents).complete.to_s
    end
  end
end
