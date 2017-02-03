module Flutterby
  module Url
    # Returns the node's URL.
    #
    def url
      path
    end

    def path
      raise "node has been deleted" if deleted?
      File.join(parent ? parent.path : "/", full_name)
    end
  end
end
