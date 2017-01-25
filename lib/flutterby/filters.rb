require 'erubis'
require 'erubis/auto'
require 'sass'
require 'tilt'
require 'slim'
require 'builder'
require 'flutterby/markdown_formatter'

module Flutterby
  module Filters
    def self.apply!(input, view:)
      # Apply all filters
      view.node.filters.inject(input) do |body, filter|
        meth = "process_#{filter}!"

        if Filters.respond_to?(meth)
          Filters.send(meth, body, view: view)
        elsif template = tilt(filter, body)
          template.render(view).html_safe
        else
          Flutterby.logger.warn "Unsupported filter '#{filter}' for #{view.node.url}"
          body
        end
      end
    end

    def self.add(fmts, &blk)
      Array(fmts).each do |fmt|
        define_singleton_method("process_#{fmt}!", &blk)
      end
    end

    def self.tilt(format, body, options = {})
      default_options = {
        "erb" => { engine_class: Erubis::Auto::EscapedEruby }
      }

      options = default_options.fetch(format, {}).merge(options)

      t = Tilt[format] and t.new(options) { body }
    end
  end
end

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
