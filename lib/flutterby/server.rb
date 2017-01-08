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

        puts "Change detected, reloading everything!"
        @root.reload!
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
      server.run self, Port: @port
    end

    def call(env)
      req  = Rack::Request.new(env)
      res = Rack::Response.new([], 200, {})

      parts = req.path.split("/").reject(&:empty?)

      result = catch :halt do
        serve(@root, parts, req, res)
      end

      case result
      when :error_404 then
        res.status = 404
        res.headers["Content-Type"] = "text/html"
        res.body = ["404"]
      end

      res
    end

    def serve(node, parts, req, res)
      # halt if we're not supposed to serve current entity
      throw :halt, :error_404 unless node.should_publish?

      # If there are parts left, find them and delegate to the next
      # node in the chain; otherwise, render this specific node.
      #
      if parts.any?
        if child = node.find(parts.shift)
          serve(child, parts, req, res)
        else
          throw :halt, :error_404
        end
      elsif child = node.find("index")
        serve(child, parts, req, res)
      else
        # Determine MIME type
        mime_type = MIME::Types.type_for(node.ext) || "text/plain"

        # Build response
        res.headers["Content-Type"] = mime_type
        res.body = [node.render]
        throw :halt
      end
    end
  end
end
