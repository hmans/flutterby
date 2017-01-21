# Flutterby

### A flexible, Ruby-powered static site generator.

[![Gem Version](https://badge.fury.io/rb/flutterby.svg)](https://badge.fury.io/rb/flutterby) [![Build Status](https://travis-ci.org/hmans/flutterby.svg?branch=master)](https://travis-ci.org/hmans/flutterby) [![license](https://img.shields.io/github/license/hmans/flutterby.svg)](https://github.com/hmans/flutterby/blob/master/LICENSE.txt) ![Status](https://img.shields.io/badge/status-active-brightgreen.svg)


#### Key Features:

- Generate a static website from a source directory!
- Apply any number of transformations on files!
- Built-in support for Markdown, Sass, Erb, Slim and more!
- Extremely easy to extend with new transformation filters!
- Sprinkle your site with Ruby code that can interact with your site's pages and data!

#### Recommended Reading:

- [Blog post introducing Flutterby](http://hmans.io/posts/2017/01/11/flutterby.html)
- [New project template](https://github.com/hmans/flutterby/tree/master/lib/templates/new_project) (example code)
- [Version History](https://github.com/hmans/flutterby/blob/master/CHANGES.md)
- [Roadmap](https://github.com/hmans/flutterby/projects/1)
- [Sites built with Flutterby](https://github.com/hmans/flutterby/wiki/Sites-built-with-Flutterby) (add yours!)


## Installation & Basic Usage

Flutterby is distributed as a RubyGem, so let's install it first:

    gem install flutterby

This will install a `flutterby` executable on your system. Let's use it to create a new project:

    flutterby new mysite
    cd mysite

The new project template serves as a simple starting point for new projects. Let's compile it into a static site:

    flutterby build

Flutterby comes with a local development server that will automatically pick up changes you make to your files:

    flutterby serve

**Note**: by default, both the `build` and `serve` commands assume `./site/` to be the source directory and `./_build/` to be the export directory. Please refer to `flutterby help` to see how you can override these.



## Notes

### How does Flutterby work?

#### The Basics:

Flutterby reads a _source directory_ and writes a static website into a _target directory_. (It can also serve a live version of your site.)

Before it writes (or serves) anything, it reads the entire contents from the source directory into a graph of plain old Ruby objects. Each of these objects represents a file (or folder) from your site.

Flutterby then walks this tree to write the resulting static site, optionally _applying filters_ first. For example, `index.html.md` will be exported as `index.html` after applying a Markdown filter.

These filters can be anything that modifies the Ruby object. Some examples:

- Rendering Markdown to HTML
- Parsing and executing ERB, Slim, HAML and other templating engines
- Processing Sass, CoffeeScript and the likes
- Leaving the current body intact, but modifying file attributes like the generated file's extension

Filters can be chained at any length you require.

Files and folders starting with underscores (eg. `_secret.html`) will never be exported. There's a number of special files that start with this underscore -- more on that later.

#### Using Ruby in templates:

Ruby code embedded in ERB, Slim etc. templates can interact with this object graph to do funky stuff like:

- including the rendered contents of another object (ie. partials)
- query the graph for certain objects (eg. "all objects in `/posts` that have `published_at` set")
- and much more, I guess!

#### Layout files:

When a `_layout` file is available in the same folder as the rendered page, it will be used to wrap the object's rendered output. These layout files stack, so you can have a `/posts/_layout.erb` with the layout for a single post, and a `/_layout.erb` with the layout of your site.

#### Extending views:

When a `_view.rb` file is available in the same folder as the rendered page, it will be evaluated against the current view object, allowing you to define your own view helpers. Like layouts, these will stack.

#### Writing Ruby nodes:

When a file has a `.rb` filter extension, the contained Ruby code will be evaluated against the Node instance. This allows you to build Ruby-based nodes. These nodes can do some powerful things, like creating other "virtual" nodes on the fly. I'm using this technique for the [archives on my blog](https://github.com/hmans/hmans_me/tree/master/site/archive).

When a file named `_node.rb` is present, the contained code will be evaluated against _all_ nodes in the same directory. This allows you to easily extend multiple nodes with functionality. [I'm using this in the template project](https://github.com/hmans/flutterby/tree/master/lib/templates/new_project/site/blog) to add `#title` and `#date` methods to blog posts.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
