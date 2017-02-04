require 'uri'

module Flutterby
  module Url
    # Returns the node's fully qualified URL.
    #
    def url
      Flutterby.config.prefix_uri.try(:host) ?
        URI.join(Flutterby.config.prefix_uri, path).to_s : path
    end

    # Returns the node's path, taking any configured prefix into account.
    #
    def path
      Flutterby.config.prefix_uri ?
        File.join(Flutterby.config.prefix_uri.path, internal_path) : internal_path
    end

    # Return's the node's "internal" path: the path of the node that can also
    # be passed to {#find} to find it, not taking any configured --prefix
    # into account.
    #
    def internal_path
      raise "node has been deleted" if deleted?
      File.join(parent ? parent.internal_path : "/", full_name)
    end
  end
end
