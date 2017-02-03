module Flutterby
  module Url
    # Returns the node's URL.
    #
    def url
      deleted? ? nil : ::File.join(parent ? parent.url : "/", full_name)
    end
  end
end
