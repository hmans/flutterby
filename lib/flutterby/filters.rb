require 'erubis'
require 'erubis/auto'
require 'sass'
require 'tilt'
require 'slim'
require 'builder'
require 'flutterby/markdown_formatter'

module Flutterby
  module Filters
    def self.apply!(view)
      view._body = view.source.try(:html_safe)

      # Apply all filters
      view.node.filters.each do |filter|
        meth = "process_#{filter}!"

        if Filters.respond_to?(meth)
          Filters.send(meth, view)
        elsif template = tilt(filter, view._body)
          view._body = template.render(view).html_safe
        else
          Flutterby.logger.warn "Unsupported filter '#{filter}' for #{view.node.url}"
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

Flutterby::Filters.add("rb") do |view|
  view._body = view.instance_eval(view._body)
end

Flutterby::Filters.add(["md", "markdown"]) do |view|
  view._body = Flutterby::MarkdownFormatter.new(view._body).complete.to_s.html_safe
end

Flutterby::Filters.add("scss") do |view|
  sass_options = {
    syntax: :scss,
    load_paths: []
  }

  if view.node.fs_path
    sass_options[:load_paths] << File.dirname(view.node.fs_path)
  end

  view._body = Sass::Engine.new(view._body, sass_options).render
end
