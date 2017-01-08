require 'commander'
require 'flutterby'

Commander.configure do
  program :name, 'Flutterby'
  program :version, Flutterby::VERSION
  program :description, 'There are many static site generators. This one is mine.'

  command :build do |c|
    c.syntax = 'flutterby build [options]'
    c.description = "Build your website."

    c.option '--in DIR', String, "Directory containing your source files"
    c.option '--out DIR', String, "Target directory"

    c.action do |args, options|
      options.default in: "./site/", out: "./_build/"

      root = Flutterby.from(options.in, name: "/")
      root.export(options.out)
    end
  end
  alias_command :b, :build

  command :serve do |c|
    c.syntax = 'flutterby serve [options]'
    c.description = "Serve your website for development."

    c.option '--in DIR', String, "Directory containing your source files"
    c.option '--port NUM', String, "Port to serve on (default: 4004)"

    c.action do |args, options|
      options.default in: "./site/", port: 4004

      root = Flutterby.from(options.in, name: "/")
      server = Flutterby::Server.new(root, port: options.port)
      server.run!
    end
  end
  alias_command :server, :serve
  alias_command :s, :serve
end
