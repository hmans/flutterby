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
      server.run @root
    end
  end
end
