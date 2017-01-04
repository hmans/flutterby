require 'slodown'
require 'sass'

module Flutterby
  class File < Entity
    def read
      @contents = ::File.read(@path)
    end

    def process
      while ext = extensions.pop do
        meth = "process_#{ext}"
        if respond_to?(meth)
          send(meth)
        else
          puts "Woops, no #{meth} available :("
        end
      end
    end

    def process_erb
      @contents = ERB.new(@contents).result
    end

    def process_md
      @contents = Slodown::Formatter.new(@contents).complete.to_s
    end

    def process_scss
      engine = Sass::Engine.new(@contents, syntax: :scss)
      @contents = engine.render
    end

    def write(path)
      ::File.write(path, @contents)
    end
  end
end
