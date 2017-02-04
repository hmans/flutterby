module Flutterby
  class Config
    attr_reader :prefix, :prefix_uri

    def prefix=(prefix)
      @prefix_uri = prefix && URI(prefix)
      @prefix = prefix
    end
  end
end
