module Flutterby
  class Exporter
    def initialize(root)
      @root = root
    end

    def export!(into:, threads: 1)
      # Set up queue
      q = Queue.new
      @root.all_nodes.each { |node| q.push(node) }

      # Work through queue
      workers = (1..threads).map do
        Thread.new do
          begin
            while node = q.pop(true)
              export_node(node, into: into)
            end
          rescue ThreadError
          end
        end
      end.map(&:join)
    end

    private

    def export_node(node, into:)
      return unless node.should_publish?

      path = ::File.expand_path(::File.join(into, node.internal_path))

      if node.file?
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, node.render(layout: true))
        logger.info "Exported #{node.internal_path.colorize(:light_white)}"
      else
        FileUtils.mkdir_p(path)
      end
    end

    def logger
      @logger ||= Flutterby.logger
    end
  end
end
