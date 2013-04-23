# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'unified/version'

Gem::Specification.new do |spec|
  spec.name          = "unified"
  spec.version       = Unified::VERSION
  spec.authors       = ["Matthew Williams"]
  spec.email         = ["m.williams@me.com"]
  spec.description   = %q{A gem for parsign unified diff files into usable Ruby objects}
  spec.summary       = %q{A gem for parsing unified diff files into usable Ruby objects}
  spec.homepage      = "https://github.com/mrwillihog/unified"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.13.1"

  spec.add_runtime_dependency "parslet", "~> 1.5"
end
