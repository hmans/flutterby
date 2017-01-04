module Flutterby
  class File < Entity
    def read
      @contents = ::File.read(@path)
    end

    def process
      while ext = extensions.pop do
        klass = case ext
        when "md" then SlodownProcessor
        end

        if klass
          processor = klass.new(@contents)
          @contents = processor.process
        end
      end
    end

    def write(path)
      ::File.write(path, @contents)
    end
  end
end
