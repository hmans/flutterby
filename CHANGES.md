# Version History

### HEAD

- **NEW:** Event system! (TODO: add link to tutorial.)


### 0.6.2 (2017-01-29)

- **FIXED:** Images and other binaries would crash Flutterby when trying to extract frontmatter from them. Woops! ([#29](https://github.com/hmans/flutterby/issues/29))


### 0.6.1 (2017-01-29)

- **FIXED:** Front matter is now extracted using a non-greedy regular expression, fixing the problem with `---` horizontal rules in Markdown bodies.


### 0.6.0 (2017-01-26)

- **NEW:** Within a view context, you can now invoke `render(node, as: "foo")`, and it will use a `_foo` partial in the same folder as `node`, passing `node` as a `foo` local. This allows you to easily apply decorator partials to nodes.
- **NEW:** When invoking `Node#render`, you now have additional control over the layout behavior through the `layout` argument. Like before, when `true`, the default page layouts will be applied; when `false`, no layout will be applied whatsoever; but now you can also pass one or more nodes (or node selectors) that will be applied as layouts.
- **BREAKING:** If you want to pass locals to `render`, you now need to use the `locals:` key. Example: `node.render(locals: { foo: "bar" })`
- **IMPROVED:** The new project template has received some minor improvements, including a `Rakefile` containing an example `deploy` task.


### 0.5.2 (2017-01-25)

- **NEW:** Just like `find`, there is now also a `find!` that will raise an exception when the specified node could not be found.
- **NEW:** Nodes can now control the layout(s) that will be applied to them in their front matter through the `layout` keyword.


### 0.5.1 (2017-01-24)

- **NEW:** Views now provide an `extend_view` method that you can (and should) use in `_view.rb` extensions.
- **NEW:** Improved log output, especially when using `--debug`.


### 0.5.0 (2017-01-24)

- **NEW:** Nodes have two new attributes, `prefix` and `slug`, which are automatically generated from the node's name. If the name starts with a combination of decimals and dashes, these will become the `prefix`, and the remainder auf the name the `suffix`. For example, a name of `123-introduction` will result in a prefix of `123` and a slug of `introduction`. As before, a prefix that looks like a date (eg. `2017-04-01-introduction`) will automatically be parsed into `data[:date]`.
- **NEW:** When nodes are being spawned, their names will be changed to their slugs by default (ie. any prefix contained in the original name will be removed.) For example, a `123-foo.html.md` will be exported as just `foo.html`.
- **NEW:** Nodes now have first-class support of a node title through the new `title` attribute. This will either use `data[:title]`, when available, or generate a title from `slug` (eg. a node named `hello-world.html.md` will automatically have a title of `Hello World`.)
- **NEW:** You can now also access a node's data using a convenient dot syntax; eg. `node.data.foo.bar` will return `node.data[:foo][:bar]`. If you're on Ruby 2.3 or newer, this allows you to use the safe navigation operator; eg. `data.foo&.bar`.
- **BREAKING CHANGE:** The `_node.rb` mechanism is gone. In its stead, you can now add `_init.rb` files that will be evaluated automatically; those can use the new `extend_siblings` and `extend_parent` convenience methods to extend all available siblings (or the parent) with the specified module or block.
- **NEW:** These node extensions can now supply an `on_setup` block that will be executed after the tree has been fully spawned. You can use these setup blocks to further modify the tree.
- **NEW:** The `flutterby build` and `flutterby serve` CLI commands now provide additional debug output when started with the `--debug` option.
- **NEW:** Added `Node#create` as a convenience method for creating new child nodes below a given node.
- **CHANGE:** Some massive refactoring, the primary intent being to perform the rendering of nodes in a thread-safe manner.


### 0.4.0 (2017-01-21)

- **NEW:** Flutterby views now have a `tag` helper method available that can generate HTML tags programatically.
- **NEW:** Flutterby views now have a `link_to` helper method available that renders link tags. You can use a URL string as the link target, eg. `link_to "Home", "/"`, or any Flutterby node, eg. `link_to "Blog", blog_node`.
- **NEW:** Flutterby views now have a `debug` helper that will dump its argument's YAML representation into a `<pre>` HTML tag (similar to Rails.)


### 0.3.1 (2017-01-15)

- **NEW:** Flutterby now uses ActiveSupport. It's a big dependency, but there's just so much useful goodness in there -- let's ride on the shoulders of that giant! This allows you to use all the neat little ActiveSupport toys you may know from Rails in your Flutterby project.
- **CHANGE:** Thanks to the new inclusion of ActiveSupport, Flutterby now properly deals with HTML escaping (by way of `ActiveSupport::SafeBuffer`). This may not be critically important to static sites, but since Flutterby aspires to also power live sites, better make this change now than later. To sum things up, Flutterby now deals with HTML escaping pretty much like Rails does. Hooray!


### 0.2.0 (2017-01-13)

- **BREAKING CHANGE:** The default for `Node#render` is now to _not_ render a layout. Pass `layout: true` if you do want the node to be rendered within a layout.
- **BREAKING CHANGE:** The behavior of `find` has now changed with regard to relative paths. `find(".")` will now return _the node's parent_ (ie. it's folder); before, a single dot would return the node itself. This change was made to make `find` behave more like what you would expect from a file system.
- **CHANGE:** Stop the [Slodown] library from picking up Coderay et al to perform server-side syntax highlighting. This will probably be made configurable at some point in the future. For the time being, it is recommended to perform syntax highlighting through client-side libraries like [highlight.js].
- **NEW:** You can now pass options to rendered partials. For example, when you invoke `<%= render("_foo.html.erb", name: "bar") %>`, `_foo.html.erb` can use `opts[:name]`.
- **NEW:** `flutterby serve` now properly catches and displays exceptions via the [better_errors](https://github.com/charliesome/better_errors) gem.
- **NEW:** For filters not natively supported by Flutterby, it will now fall back to [Tilt]. This means you can just add any gem supported by Tilt to your project to use it as a template language, with no Flutterby-specific plugin required. Hooray!
- **NEW:** the `flutterby` CLI now has a `version` command that will print the version of Flutterby you're using.


### 0.1.0 (2017-01-11)

- First release!




[Tilt]: https://github.com/rtomayko/tilt
[Slodown]: http://github.com/hmans/slodown
[highlight.js]: https://highlightjs.org/
