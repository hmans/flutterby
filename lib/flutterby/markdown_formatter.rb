require 'slodown'

module Flutterby
  class MarkdownFormatter < Slodown::Formatter
    def complete
      markdown.autolink.sanitize
    end

    def kramdown_options
      {
        input: "GFM",
        hard_wrap: false,
        syntax_highlighter: nil,
        syntax_highlighter_opts: { }
      }
    end
  end
end
