# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "scamp/version"

Gem::Specification.new do |s|
  s.name        = "scamp"
  s.version     = Scamp::VERSION
  s.authors     = ["Will Jessop"]
  s.email       = ["will@willj.net"]
  s.homepage    = "https://github.com/wjessop/Scamp"
  s.summary     = %q{Eventmachine based Campfire bot framework}
  s.description = %q{Eventmachine based Campfire bot framework}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('eventmachine', '~> 1.0.0.beta.4')
  s.add_dependency('yajl-ruby', '~> 0.8.3')
  s.add_dependency('em-http-request', '~> 1.0.0.beta.4')

  s.add_development_dependency "rspec", "~> 2.6.0"
  s.add_development_dependency "mocha", "~> 0.10.0"
  s.add_development_dependency "webmock", "~> 1.7.6"
end
