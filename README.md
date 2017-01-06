# Flutterby

A currently highly experimental static site generator. Yes, there are many like it;
but this one is mine. (Actually, there are none like it. Ha! I'm very serious about
the _experimental_ bit, though. Use with care, if at all!)


## Actual Features

- Build your site simply as a tree of files and folders. Each file will be converted according to its extension chain (eg. `styles.css.scss` will be rendered as `styles.css`, `about.html.md` as `about.html` and so on.)
- Built-in support for Markdown (by way of [Slodown](https://github.com/hmans/slodown)), [Sass](https://github.com/sass/sass), [ERB](http://ruby-doc.org/stdlib-2.4.0/libdoc/erb/rdoc/ERB.html) and [Slim](http://slim-lang.com/).
- A (slow) HTTP server to serve your site dynamically (for development.)
- Dynamically enhance your site's functionality with Ruby code.


## Missing (but Planned) Features

- Extract filters (like Slim, Sass etc.) to separate gems
- Produce a fun screencast to explain what the heck is going on here!
- More tests, of course!


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
