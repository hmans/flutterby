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

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

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

  spec.add_dependency 'slodown'
  spec.add_dependency 'sass'
  spec.add_dependency 'tilt'
  spec.add_dependency 'slim'
  spec.add_dependency 'toml-rb'
  spec.add_dependency 'rack'
end
