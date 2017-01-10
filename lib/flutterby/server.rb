require 'rack'
require 'listen'

module Flutterby
  class Server
    def initialize(root, port: 4004)
      @root = root
      @port = port
    end

    def run!
      # Set up listener
      listener = Listen.to(@root.fs_path) do |modified, added, removed|
        # puts "modified absolute path: #{modified}"
        # puts "added absolute path: #{added}"
        # puts "removed absolute path: #{removed}"

        Flutterby.logger.info "Change detected, reloading everything!"
        @root.reload!
        @root.stage!
      end

      # Set up server
      server = Rack::Handler::WEBrick

      # Make sure we handle interrupts correctly
      trap('INT') do
        listener.stop
        server.shutdown
      end

      # Go!
      listener.start
      server.run self, Port: @port, Logger: Flutterby.logger
    end

    def call(env)
      req  = Rack::Request.new(env)
      res = Rack::Response.new([], 200, {})

      # Look for target node in path registry
      if node = find_node_for_path(req.path)
        # Determine MIME type
        mime_type = MIME::Types.type_for(node.ext) || "text/plain"

        # Build response
        res.headers["Content-Type"] = mime_type
        res.body = [node.render]
      else
        res.status = 404
        res.headers["Content-Type"] = "text/html"
        res.body = ["404"]
      end

      res
    end

    def find_node_for_path(path)
      @root.paths[path] ||
      @root.paths[path + ".html"] ||
      @root.paths[::File.join(path, "index.html")]
    end
  end
end
