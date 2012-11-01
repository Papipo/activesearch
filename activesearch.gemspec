# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'activesearch/version'

Gem::Specification.new do |gem|
  gem.name          = "activesearch"
  gem.version       = ActiveSearch::VERSION
  gem.authors       = ["Rodrigo Alvarez"]
  gem.email         = ["papipo@gmail.com"]
  gem.description   = %q{ORM agnostic full text search}
  gem.summary       = %q{ActiveSearch lets you plug in a ruby module in any class that will allow you to do full text searches.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "bson_ext"
  gem.add_development_dependency "active_attr"
  gem.add_development_dependency "mongoid", "~> 2"
  gem.add_development_dependency "tire"
  gem.add_development_dependency "parallel_tests"
end