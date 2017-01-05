require 'commander'

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
      say "Yo."
      puts options.inspect
    end
  end
end
