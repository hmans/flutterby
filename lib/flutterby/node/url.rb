require 'uri'

module Flutterby
  module Url
    # Returns the node's URL.
    #
    def url
      Flutterby.config.prefix ?
        URI.join(Flutterby.config.prefix, path).to_s : path
    end

    def path
      raise "node has been deleted" if deleted?

      path = File.join(parent ? parent.path : "/", full_name)

      root? && Flutterby.config.prefix ?
        File.join(URI(Flutterby.config.prefix).path, path) : path
    end
  end
end
