# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'flutterby/version'

Gem::Specification.new do |spec|
  spec.name          = "flutterby"
  spec.version       = Flutterby::VERSION
  spec.authors       = ["Hendrik Mans"]
  spec.email         = ["hendrik@mans.de"]

  spec.summary       = %q{A flexible, Ruby-powered website creation framework.}
  spec.description   = %q{Flutterby is a flexible, Ruby-powered, routing graph-based web application framework that will serve your website dynamically or export it as a static site.}
  spec.homepage      = "https://github.com/hmans/flutterby"
  spec.license       = "MIT"

  spec.post_install_message = %q{Please note that Flutterby is still under heavy development. If you use it to build a website, please expect breakage in future versions! Please keep an eye (or two) on the official website at <http://flutterby.run>.}

  spec.required_ruby_version = '~> 2.2'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = ["flutterby"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-its", "~> 1.2"
  spec.add_development_dependency 'awesome_print', '~> 1.7'
  spec.add_development_dependency 'gem-release', '~> 0.7'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'yard', '~> 0.9'

  spec.add_dependency 'colorize', '~> 0.8'
  spec.add_dependency 'erubis', '~> 2.7'
  spec.add_dependency 'erubis-auto', '~> 1.0'
  spec.add_dependency 'json', '~> 2.0'
  spec.add_dependency 'thor', '~> 0.19'
  spec.add_dependency 'highline', '~> 1.7'
  spec.add_dependency 'slodown', '~> 0.4'
  spec.add_dependency 'toml-rb', '~> 0.3'
  spec.add_dependency 'rack', '~> 2.0'
  spec.add_dependency 'listen', '~> 3.1'
  spec.add_dependency 'mime-types', '~> 3.1'
  spec.add_dependency 'better_errors', '~> 2.1'
  spec.add_dependency 'activesupport', '~> 5.0'

  # LiveReload related
  spec.add_dependency 'rack-livereload', '~> 0.3.16'
  spec.add_dependency 'em-websocket', '~> 0.5.1'

  # We support some template engines out of the box.
  # There's a chance these will be extracted/made optional
  # at some point in the future.
  spec.add_dependency 'sass', '~> 3.4'
  spec.add_dependency 'builder', '~> 3.2'
  spec.add_dependency 'slim', '~> 3.0'
  spec.add_dependency 'tilt', '~> 2.0'
end
