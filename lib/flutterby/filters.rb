module Flutterby
  module Filters
    def self.apply!(node)
      node.body = node.source

      # Apply all filters
      node.filters.each do |filter|
        meth = "process_#{filter}!"

        if Filters.respond_to?(meth)
          Filters.send(meth, node)
        end
      end
    end

    def self.add(fmts, &blk)
      Array(fmts).each do |fmt|
        define_singleton_method("process_#{fmt}!", &blk)
      end
    end

    def self.tilt(format, body)
      Tilt[format].new { body }
    end
  end
end

Flutterby::Filters.add("rb") do |node|
  node.instance_eval(node.body)
end

Flutterby::Filters.add("erb") do |node|
  node.body = tilt("erb", node.body).render(node.view)
end

Flutterby::Filters.add("slim") do |node|
  node.body = tilt("slim", node.body).render(node.view)
end

Flutterby::Filters.add(["md", "markdown"]) do |node|
  node.body = Slodown::Formatter.new(node.body).complete.to_s
end

Flutterby::Filters.add("scss") do |node|
  node.body = Sass::Engine.new(node.body, syntax: :scss).render
end
