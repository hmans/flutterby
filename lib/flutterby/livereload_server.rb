require 'em-websocket'

module Flutterby
  class LiveReloadServer
    attr_reader :options

    DEFAULT_OPTIONS = {
      host: "localhost",
      port: 35729
    }

    def initialize(root, options = {})
      @root = root
      @options     = DEFAULT_OPTIONS.merge(options)
      @web_sockets = []
      @mutex       = Thread::Mutex.new
      @thread      = start
    end

    def logger
      Flutterby.logger
    end

    def stop
      thread.kill
    end

    def reload_browser(paths = [])
      paths = Array(paths)
      logger.info "== LiveReloading path: #{paths.join(' ')}"
      paths.each do |path|
        # Find node corresponding to path
        if node = @root.find_for_fs_path(path)
          path = node.url
        end

        data = JSON.dump(['refresh', {
          :path           => path,
          :apply_js_live  => true,
          :apply_css_live => true
        }])

        @web_sockets.each { |ws| ws.send(data) }
      end
    end

    def start
      logger.info "Starting LiveReload websocket server"
      Thread.new do
        EventMachine.run do
          EventMachine.start_server(options[:host], options[:port], EventMachine::WebSocket::Connection, {}) do |ws|
            ws.onopen do
              begin
                ws.send "!!ver:1.6"
                @web_sockets << ws
                logger.debug "== LiveReload browser connected"
              rescue
                logger.error $!
                logger.error $!.backtrace
              end
            end

            ws.onmessage do |msg|
              logger.debug "LiveReload Browser URL: #{msg}"
            end

            ws.onclose do
              @web_sockets.delete ws
              logger.debug "== LiveReload browser disconnected"
            end
          end
        end
      end
    end
  end
end
