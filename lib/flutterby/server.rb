require 'rack'

module Flutterby
  class Server
    def initialize(root)
      @root = root
    end

    def run!
      Rack::Handler::WEBrick.run @root
    end
  end
end
