# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "meerkat/version"

Gem::Specification.new do |s|
  s.name        = "meerkat"
  s.version     = Meerkat::VERSION
  s.authors     = ["Carl Hörberg"]
  s.email       = ["carl.hoerberg@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Ruby EventSource, Rack style}
  s.description = %q{Requires Thin}

  s.rubyforge_project = "meerkat"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "minitest"
  s.add_development_dependency "rack-test"
  s.add_development_dependency "thin-async-test"
  s.add_development_dependency "em-minitest-spec"

  s.add_runtime_dependency "yajl-ruby"
  s.add_runtime_dependency "eventmachine"
  s.add_runtime_dependency "thin_async"
  s.add_runtime_dependency "hiredis"
  s.add_runtime_dependency "em-synchrony"
  s.add_runtime_dependency "redis"
end
