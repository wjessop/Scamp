# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "scamp/version"

Gem::Specification.new do |s|
  s.name        = "scamp"
  s.version     = Scamp::VERSION
  s.authors     = ["Will Jessop", "Adam Holt"]
  s.email       = ["will@willj.net", "me@adamholt.co.uk"]
  s.homepage    = "https://github.com/wjessop/Scamp"
  s.summary     = %q{Eventmachine based Campfire bot framework}
  s.description = %q{Eventmachine based Campfire bot framework}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'eventmachine', '~> 1.0'

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", '~> 2.11'
  s.add_development_dependency "mocha", '~> 0.12'
  s.add_development_dependency "webmock", '~> 1.8'
  s.add_development_dependency "simplecov"
end
