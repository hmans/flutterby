[![Gem Version](https://badge.fury.io/rb/flutterby.svg)](https://badge.fury.io/rb/flutterby) [![Build Status](https://travis-ci.org/hmans/flutterby.svg?branch=master)](https://travis-ci.org/hmans/flutterby) ![Status](https://img.shields.io/badge/status-active-brightgreen.svg)

# Flutterby

### A currently highly experimental static site generator. Yes, there are many like it; but this one is mine. (Actually, there are none like it. Ha! I'm very serious about the _experimental_ bit, though. Use with care, if at all!)


## Actual Features

- Build your site simply as a tree of files and folders. Each file will be converted according to its extension chain (eg. `styles.css.scss` will be rendered as `styles.css`, `about.html.md` as `about.html` and so on.)
- Built-in support for Markdown (by way of [Slodown](https://github.com/hmans/slodown)), [Sass](https://github.com/sass/sass), [ERB](http://ruby-doc.org/stdlib-2.4.0/libdoc/erb/rdoc/ERB.html) and [Slim](http://slim-lang.com/).
- A (slow) HTTP server to serve your site dynamically (for development.)
- Dynamically enhance your site's functionality with Ruby code.


## Missing (but Planned) Features

- Extract filters (like Slim, Sass etc.) to separate gems
- Produce a fun screencast to explain what the heck is going on here!
- More tests, of course!

## How does Flutterby work?

A loose collection of notes on how Flutterby actually generates your site -- mostly intended as rubberducking with myself.

- Flutterby reads a _source directory_ and writes a static website into a _target directory_. (It can also serve a live version of your site.)
- Before it writes (or serves) anything, it reads the entire contents from the source directory into a graph of plain old Ruby objects. Each of these objects represents a file (or folder) from your site.
- Flutterby then walks this tree to write the resulting static site, optionally _applying filters_ first. For example, `index.html.md` will be exported as `index.html` after applying a Markdown filter.
- These filters can be anything that modifies the Ruby object. Some examples:
  - Rendering Markdown to HTML
  - Parsing and executing ERB, Slim, HAML and other templating engines
  - Processing Sass, CoffeeScript and the likes
  - Leaving the current body intact, but modifying file attributes like the generated file's extension
- Filters can be chained at any length you require.
- Ruby code embedded in ERB, Slim etc. templates can interact with this object graph to do funky stuff like:
  - including the rendered contents of another object (ie. partials)
  - query the graph for certain objects (eg. "all objects in `/posts` that have `published_at` set")
  - and much more, I guess!
- When a `_layout` object is available in the same folder as the rendered object, it will be used to wrap the object's rendered output. These layout files stack, so you can have a `/posts/_layout.erb` with the layout for a single post, and a `/_layout.erb` with the layout of your site.
- When a `_view.rb` object is available in the same folder as the rendered object, it will be evaluated against the current view, allowing you to define your own view helpers. Like layouts, these will stack.
- Files and folders starting with underscores (eg. `_header.html`) will never be exported.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
