require 'rack'
require 'listen'
require 'better_errors'

module Flutterby
  class Server
    def initialize(root)
      @root = root
    end

    def run!(port: 4004)
      # Set up listener
      listener = Listen.to(@root.fs_path) do |modified, added, removed|
        puts "modified absolute path: #{modified}"
        puts "added absolute path: #{added}"
        puts "removed absolute path: #{removed}"

        modified.each do |fs_path|
          if node = @root.find_for_fs_path(fs_path)
            logger.info "Reloading node #{node}"
            node.reload!
          end
        end

        added.each do |fs_path|
          if parent = @root.find_for_fs_path(File.dirname(fs_path))
            logger.info "Adding node to #{parent}"
            node = parent.create(File.basename(fs_path), fs_path: fs_path)
            node.stage!
            node.handle(:created)
          end
        end

        removed.each do |fs_path|
          if node = @root.find_for_fs_path(fs_path)
            logger.info "Removing node #{node}"
            node.delete!
          end
        end
      end

      # Set up Rack app
      BetterErrors.application_root = __dir__
      this = self
      app = Rack::Builder.app do |app|
        app.use BetterErrors::Middleware
        app.run this
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
      if node = @root.find(path, public_only: true)
        # If the node is a folder, try and find its "index" node.
        # Otherwise, use the node directly.
        node.folder? ? node.find('index') : node
      end
    end

    def logger
      @logger ||= Flutterby.logger
    end
  end
end
