require 'rack'
require 'listen'
require 'better_errors'

# Try to load Puma handler
begin
  require 'rack/handler/puma'
rescue LoadError
end

module Flutterby
  class Server
    def initialize(root)
      @root = root
    end

    def run!(port: 4004)
      # Set up listener
      listener = Listen.to(@root.fs_path) do |modified, added, removed|
        # puts "modified absolute path: #{modified}"
        # puts "added absolute path: #{added}"
        # puts "removed absolute path: #{removed}"

        Flutterby.logger.info "Change detected, reloading everything!"
        @root.reload!
        @root.stage!
      end

      # Set up Rack app
      BetterErrors.application_root = __dir__
      this = self
      app = Rack::Builder.app do |app|
        app.use BetterErrors::Middleware
        app.run this
      end

      # Set up request handler
      server = if defined?(Rack::Handler::Puma)
        Rack::Handler::Puma
      else
        Rack::Handler::WEBrick
      end

      # Make sure we handle interrupts correctly
      trap('INT') do
        listener.stop
        server.shutdown
      end

      # Go!
      listener.start
      server.run app, Port: port, Logger: Flutterby.logger
    end

    def call(env)
      req = Rack::Request.new(env)
      res = Rack::Response.new([], 200, {})

      # Look for target node in path registry
      if node = find_node_for_path(req.path)
        # Determine MIME type
        mime_type = MIME::Types.type_for(node.ext) || "text/plain"

        # Build response
        res.headers["Content-Type"] = mime_type
        res.body = [node.render(layout: true)]
      else
        res.status = 404
        res.headers["Content-Type"] = "text/html"
        res.body = ["404"]
      end

      res
    end

    def find_node_for_path(path)
      if node = @root.find(path)
        # If the node is a folder, try and find its "index" node.
        # Otherwise, use the node directly.
        node.folder? ? node.find('index') : node
      end
    end
  end
end
