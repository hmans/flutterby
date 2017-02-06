require 'rack'
require 'rack/livereload'
require 'listen'
require 'better_errors'
require 'flutterby/livereload_server'

module Flutterby
  class Server
    def initialize(root)
      @root = root
    end

    def run!(address: "localhost", port: 4004)
      # Spawn livereload server
      livereload = LiveReloadServer.new(@root, { host: address })

      # Set up listener
      listener = Listen.to(@root.fs_path) do |modified, added, removed|
        @root.reload!
        livereload.trigger_reload(modified + added + removed)
        # handle_fs_change(modified, added, removed)
      end

      # Set up Rack app
      BetterErrors.application_root = __dir__
      this = self
      app = Rack::Builder.app do |app|
        app.use BetterErrors::Middleware
        app.use Rack::LiveReload, no_swf: true
        app.run this
      end

      # Set up server
      server = Rack::Handler::WEBrick

      # Make sure we handle interrupts correctly
      trap('INT') do
        listener.stop
        server.shutdown
        livereload.stop
      end

      # Go!
      listener.start
      server.run app, Host: address, Port: port, Logger: Flutterby.logger
    end

    def handle_fs_change(modified, added, removed)
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
        end
      end

      removed.each do |fs_path|
        if node = @root.find_for_fs_path(fs_path)
          logger.info "Removing node #{node}"
          node.delete!
        end
      end
    end

    def call(env)
      req = Rack::Request.new(env)
      res = Rack::Response.new([], 200, {})

      # Look for target node in path registry
      if (node = find_node_for_path(req.path)) && node.can_render?
        res.status = 200
        render_node(res, node)
      else
        res.status = 404
        if node_404 = @root.find("/404")
          render_node(res, node_404)
        else
          res.headers["Content-Type"] = "text/html"
          res.body = [File.read(File.expand_path("../../templates/404.html", __FILE__))]
        end
      end

      res
    end

    private

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

    def render_node(res, node)
      res.headers["Content-Type"] = node.mime_type.to_s
      res.body = [node.render(layout: true)]
    end
  end
end
