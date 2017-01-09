module Flutterby
  class Exporter
    def initialize(root)
      @root = root
    end

    def export!(into:)
      @root.paths.each do |path, node|
        if node.should_publish?
          path = ::File.expand_path(::File.join(into, node.url))

          if node.file?
            # Make sure directory exists
            FileUtils.mkdir_p(::File.dirname(path))

            # Write file
            ::File.write(path, node.render)
            logger.info "Exported #{node.url}"
          end
        end
      end
    end


    private

    def logger
      @logger ||= Flutterby.logger
    end
  end
end
