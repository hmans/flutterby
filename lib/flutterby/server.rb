require 'rack'
require 'listen'

module Flutterby
  class Server
    def initialize(root)
      @root = root
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
      server.run self
    end

    def call(env)
      req  = Rack::Request.new(env)
      res = Rack::Response.new([], 200, {})

      parts = req.path.split("/").reject(&:empty?)

      current = @root

      result = catch :halt do
        loop do
          # halt if we're not supposed to serve current entity
          throw :halt, :error_404 unless current.should_publish?

          case current
          when Flutterby::Folder then
            # If no further parts are requested, let's look for an index
            # document and serve that instead.
            if child = current.find(parts.empty? ? "index" : parts.shift)
              current = child
            else
              throw :halt, :error_404
            end
          when Flutterby::File then
            # Determine MIME type
            mime_type = MIME::Types.type_for(current.ext) || "text/plain"

            # Build response
            res.headers["Content-Type"] = mime_type
            res.body = [current.render]
            throw :halt
          end
        end
      end

      case result
      when :error_404 then
        res.headers["Content-Type"] = "text/html"
        res.body = ["404"]
      end

      res
    end
  end
end
