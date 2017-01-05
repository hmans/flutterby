# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'flutterby/version'

Gem::Specification.new do |spec|
  spec.name          = "flutterby"
  spec.version       = Flutterby::VERSION
  spec.authors       = ["Hendrik Mans"]
  spec.email         = ["hendrik@mans.de"]

  spec.summary       = %q{There are many static site generators. This is mine.}
  spec.description   = %q{There are many static site generators. This is mine.}
  spec.homepage      = "https://github.com/hmans/flutterby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = ["flutterby"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'awesome_print'
  spec.add_development_dependency 'gem-release'

  spec.add_dependency 'commander'
  spec.add_dependency 'slodown'
  spec.add_dependency 'sass'
  spec.add_dependency 'tilt'
  spec.add_dependency 'slim'
  spec.add_dependency 'toml-rb'
  spec.add_dependency 'rack'
  spec.add_dependency 'listen'
  spec.add_dependency 'mime-types'
end
