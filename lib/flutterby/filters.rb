require 'erubis'
require 'erubis/auto'
require 'sass'
require 'tilt'
require 'slim'
require 'builder'
require 'flutterby/markdown_formatter'

module Flutterby
  module Filters
    def self.apply!(node)
      node.body = node.source.try(:html_safe)

      # Apply all filters
      node.filters.each do |filter|
        meth = "process_#{filter}!"

        if Filters.respond_to?(meth)
          Filters.send(meth, node)
        elsif template = tilt(filter, node.body)
          node.body = template.render(node.view).html_safe
        else
          Flutterby.logger.warn "Unsupported filter '#{filter}' for #{node.url}"
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

Flutterby::Filters.add("rb") do |node|
  node.instance_eval(node.body)
end

Flutterby::Filters.add(["md", "markdown"]) do |node|
  node.body = Flutterby::MarkdownFormatter.new(node.body).complete.to_s.html_safe
end

Flutterby::Filters.add("scss") do |node|
  sass_options = {
    syntax: :scss,
    load_paths: []
  }

  if node.fs_path
    sass_options[:load_paths] << File.dirname(node.fs_path)
  end

  node.body = Sass::Engine.new(node.body, sass_options).render
end
