# Version History

### 0.3.0 (in development)


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
