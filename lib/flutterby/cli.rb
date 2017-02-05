require 'flutterby'
require 'flutterby/exporter'
require "flutterby/server"

require 'thor'
require 'thor/group'
require 'highline/import'
require 'benchmark'

Flutterby.logger.level = Logger::INFO

module Flutterby
  class CLI < Thor
    include Thor::Actions

    desc "version", "Displays Flutterby's version"
    map "-v" => :version
    map "--version" => :version
    def version
      say_hi
    end


    desc "build", "Build your static site"

    option :in,
      default: "./site/",
      aliases: ["-i"],
      desc: "Input directory."

    option :out,
      default: "./_build/",
      aliases: ["-o"],
      desc: "Output directory."

    option :prefix,
      type: :string,
      aliases: ["-p"],
      desc: "URL or path prefix (used when generating URLs for nodes.)"

    option :threads,
      type: :numeric,
      default: 1,
      aliases: ["-t"],
      desc: "Number of threads to use."

    option :debug,
      default: false,
      aliases: ["-d"],
      type: :boolean,
      desc: "Print extra debugging information."

    def build
      Flutterby.config.prefix = options.prefix
      Flutterby.logger.level = options.debug ? Logger::DEBUG : Logger::INFO

      # Simplify logger output
      Flutterby.logger.formatter = proc do |severity, datetime, progname, msg|
        " • #{msg}\n"
      end

      say_hi

      time = Benchmark.realtime do
        # Import site
        say color("📚  Importing site...", :bold)
        root = Flutterby::Node.new("/", fs_path: options.in)
        root.stage!
        say color("🌲  Read #{root.size} nodes.", :green, :bold)

        # Export site
        say color("💾  Exporting site#{options.threads > 1 ? " (using #{options.threads} threads)" : ""}...", :bold)
        Flutterby::Exporter.new(root).export!(into: options.out, threads: options.threads)
      end

      say color("✅  Done. (took #{sprintf "%.2f", time}s)", :green, :bold)
    end


    desc "serve", "Serve your site locally"

    option :in,
      default: "./site/",
      aliases: ["-i"],
      desc: "Input directory."

    option :port,
      default: 4004,
      aliases: ["-p"],
      type: :numeric

    option :debug,
      default: false,
      aliases: ["-d"],
      type: :boolean

    def serve
      Flutterby.logger.level = options.debug ? Logger::DEBUG : Logger::INFO

      say_hi

      say color("📚  Importing site...", :bold)
      root = Flutterby::Node.new("/", fs_path: options.in)
      root.stage!
      say color("🌲  Read #{root.size} nodes.", :green, :bold)

      say color("🌤  Serving your Flutterby site on http://localhost:#{options.port} - enjoy! \\o/", :bold)
      server = Flutterby::Server.new(root)
      server.run!(port: options.port)
    end


    desc "new PATH", "Create a new Flutterby project"
    def new(path)
      say_hi

      path = File.expand_path(path)
      self.destination_root = path

      say color("🏗  Creating a new Flutterby project in #{path}...", :bold)
      directory("new_project", path)
      chmod("bin/flutterby", 0755)
      chmod("bin/rake", 0755)
      in_root { bundle_install }
    end

    private

    def bundle_install
      if defined?(Bundler)
        Bundler.with_clean_env do
          run "bundle install"
        end
      else
        run "bundle install"
      end
    end

    def color(*args)
      $terminal.color(*args)
    end

    def say_hi
      say color("🦋  Flutterby #{Flutterby::VERSION}", :bold, :blue)
    end

    def self.source_root
      File.expand_path("../templates/", File.dirname(__FILE__))
    end
  end
end
