require 'erubis'
require 'erubis/auto'
require 'sass'
require 'tilt'
require 'slim'
require 'builder'
require 'flutterby/markdown_formatter'

module Flutterby
  module Filters
    extend self

    def apply!(input, filters, view:, &blk)
      # Apply all filters
      filters.inject(input) do |body, filter|
        meth = "process_#{filter}!"

        if Filters.respond_to?(meth)
          Filters.send(meth, body, view: view, &blk)
        else
          Flutterby.logger.warn "Unsupported filter '#{filter}'"
          body
        end
      end
    end

    def supported?(fmt)
      respond_to?("process_#{fmt}!")
    end

    def add(fmts, &blk)
      Array(fmts).each do |fmt|
        define_singleton_method("process_#{fmt}!", &blk)
      end
    end

    def enable_tilt(*fmts)
      Array(fmts).flatten.each do |fmt|
        add(fmt) do |input, view:, &blk|
          tilt(fmt, input).render(view, view.locals, &blk).html_safe
        end
      end
    end

    def tilt(format, body, options = {})
      default_options = {
        "erb" => { engine_class: Erubis::Auto::EscapedEruby }
      }

      options = default_options.fetch(format, {}).merge(options)

      t = Tilt[format] and t.new(options) { body }
    end
  end
end

# Add a bunch of formats that we support through Tilt
Flutterby::Filters.enable_tilt("erb", "slim", "haml",
  "coffee", "rdoc", "builder", "jbuilder")

Flutterby::Filters.add("rb") do |input, view:|
  view.instance_eval(input)
end

Flutterby::Filters.add(["md", "markdown"]) do |input, view:|
  Flutterby::MarkdownFormatter.new(input).complete.to_s.html_safe
end

Flutterby::Filters.add("scss") do |input, view:|
  sass_options = {
    syntax: :scss,
    load_paths: []
  }

  if view.node.fs_path
    sass_options[:load_paths] << File.dirname(view.node.fs_path)
  end

  Sass::Engine.new(input, sass_options).render
end
