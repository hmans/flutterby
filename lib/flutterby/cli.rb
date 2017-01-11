require 'flutterby'
require 'flutterby/exporter'
require "flutterby/server"

require 'thor'
require 'highline/import'
require 'benchmark'

Flutterby.logger.level = Logger::INFO

module Flutterby
  class CLI < Thor
    desc "build", "Build your static site"
    option :in, default: "./site/", aliases: [:i]
    option :out, default: "./_build/", aliases: [:o]

    def build
      # Simplify logger output
      Flutterby.logger.formatter = proc do |severity, datetime, progname, msg|
        " • #{msg}\n"
      end

      time = Benchmark.realtime do
        # Import site
        say color("📚  Importing site...", :bold)
        root = Flutterby::Node.new("/", fs_path: options.in)
        root.stage!
        say color("🌲  Read #{root.tree_size} nodes.", :green, :bold)

        # Export site
        say color("💾  Exporting site...", :bold)
        Flutterby::Exporter.new(root).export!(into: options.out)
      end

      say color("✅  Done. (took #{sprintf "%.2f", time}s)", :green, :bold)
    end


    desc "serve", "Serve your site locally"
    option :in, default: "./site/", aliases: [:i]
    option :port, default: 4004, aliases: [:p], type: :numeric

    def serve
      say color("📚  Importing site...", :bold)
      root = Flutterby::Node.new("/", fs_path: options.in)
      root.stage!
      say color("🌲  Read #{root.tree_size} nodes.", :green, :bold)

      say color("🌤  Serving your site on port #{options.port}. Enjoy!", :bold)
      server = Flutterby::Server.new(root, port: options.port)
      server.run!
    end


    private

    def color(*args)
      $terminal.color(*args)
    end
  end
end

Flutterby::CLI.start(ARGV)

# Commander.configure do
#   program :name, 'Flutterby'
#   program :version, Flutterby::VERSION
#   program :description, 'There are many static site generators. This one is mine.'
#
#
#   command :serve do |c|
    # c.syntax = 'flutterby serve [options]'
    # c.description = "Serve your website for development."
    #
    # c.option '--in DIR', String, "Directory containing your source files"
    # c.option '--port NUM', String, "Port to serve on (default: 4004)"
    #
    # c.action do |args, options|
    #   options.default in: "./site/", port: 4004
    #
    #   say color("📚  Importing site...", :bold)
    #   root = Flutterby::Node.new("/", fs_path: options.in)
    #   root.stage!
    #   say color("🌲  Read #{root.tree_size} nodes.", :green, :bold)
    #
    #   say color("🌤  Serving your site on port #{options.port}. Enjoy!", :bold)
    #   server = Flutterby::Server.new(root, port: options.port)
    #   server.run!
    # end
#   end
#   alias_command :server, :serve
#   alias_command :s, :serve
# end
