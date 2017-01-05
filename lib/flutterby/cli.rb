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

  command :serve do |c|
    c.syntax = 'flutterby serve [options]'
    c.description = "Serve your website for development."

    c.option '--in DIR', String, "Directory containing your source files"

    c.action do |args, options|
      options.default in: "./site/"

      root = Flutterby.from(options.in, name: "/")
      server = Flutterby::Server.new(root)
      server.run!
    end
  end


  command :test do |c|
    c.syntax = 'flutterby test'
    c.description = 'TEST. Yo.'
    c.action do |args, options|
      root = Flutterby.from("./in", name: "/")
      root.list
      root.export("./out/")
    end
  end
end
