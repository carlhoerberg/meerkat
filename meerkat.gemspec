# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "meerkat/version"

Gem::Specification.new do |s|
  s.name        = "meerkat"
  s.version     = Meerkat::VERSION
  s.authors     = ["Carl Hörberg"]
  s.email       = ["carl.hoerberg@gmail.com"]
  s.homepage    = "https://github.com/carlhoerberg/meerkat"
  s.summary     = %q{Rack middleware for HTML5 Server-Sent Events, with swappable backends}
  s.description = %q{Requires an evented Ruby dispatcher, like Thin}

  s.rubyforge_project = "meerkat"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
  s.add_development_dependency "rack-test"
  s.add_development_dependency "thin_async"
  s.add_development_dependency "thin-async-test"

  s.add_development_dependency "pg"
  s.add_development_dependency "amqp"
  s.add_development_dependency "em-hiredis"

  s.add_runtime_dependency "multi_json"
  s.add_runtime_dependency "eventmachine"
end
