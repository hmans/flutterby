# Version History

### 0.2.0 (in development)

- CHANGED: The default for `Node#render` is now to _not_ render a layout. Pass `layout: true` if you do want the node to be rendered within a layout.
- NEW: For filters not natively supported by Flutterby, it will now fall back to [Tilt]. This means you can just add any gem supported by Tilt to your project to use it as a template language, with no Flutterby-specific plugin required. Hooray!

### 0.1.0 (2017-01-11)

- First release!




[Tilt]: https://github.com/rtomayko/tilt
