module Flutterby
  class Exporter
    def initialize(root)
      @root = root
    end

    def export!(into:)
      export_node(@root, into: into)
    end

    private

    def export_node(node, into:)
      return unless node.should_publish?

      path = ::File.expand_path(::File.join(into, node.full_name))

      if node.file?
        ::File.write(path, node.render(layout: true))
        logger.info "Exported #{node.url.colorize(:light_white)}"
      else
        FileUtils.mkdir_p(path)
        node.children.each do |child|
          export_node(child, into: path)
        end
      end
    end

    def logger
      @logger ||= Flutterby.logger
    end
  end
end
