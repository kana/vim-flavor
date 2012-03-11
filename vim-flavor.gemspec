# -*- encoding: utf-8 -*-
require File.expand_path('../lib/vim-flavor/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Kana Natsuno"]
  gem.email         = ["dev@whileimautomaton.net"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "vim-flavor"
  gem.require_paths = ["lib"]
  gem.version       = Vim::Flavor::VERSION
end
