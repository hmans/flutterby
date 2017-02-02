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
      @options = DEFAULT_OPTIONS.merge(options)
      @sockets = []
      @thread = start
    end

    def stop
      @thread.kill
    end

    def trigger_reload(paths = [])
      Array(paths).each do |path|
        # Find node corresponding to path
        if node = @root.find_for_fs_path(path)
          path = node.url
        end

        data = JSON.dump(['refresh', {
          path: path,
          apply_js_live: true,
          apply_css_live: true
        }])

        @sockets.each { |ws| ws.send(data) }
      end
    end


    private

    def start
      logger.info "Starting LiveReload websocket server on #{options[:host]}:#{options[:port]}"
      Thread.new do
        EventMachine.run do
          EventMachine.start_server(options[:host], options[:port], EventMachine::WebSocket::Connection, {}) do |ws|
            ws.onopen do
              begin
                @sockets << ws
                ws.send "!!ver:1.6"
              rescue
                logger.error $!
              end
            end

            ws.onmessage do |msg|
              logger.debug "LiveReload message: #{msg}"
            end

            ws.onclose do
              @sockets.delete(ws)
            end
          end
        end
      end
    end

    def logger
      Flutterby.logger
    end
  end
end
