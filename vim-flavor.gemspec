# -*- encoding: utf-8 -*-
require File.expand_path('../lib/vim-flavor/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Kana Natsuno']
  gem.email         = ['dev@whileimautomaton.net']
  gem.description   = %q{See the README file.}
  gem.summary       = %q{A tool to manage your favorite Vim plugins}
  gem.homepage      = ''

  gem.executables   = `git ls-files -- bin/*`.split(/\n/).map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split(/\n/)
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split(/\n/)
  gem.name          = 'vim-flavor'
  gem.require_paths = ['lib']
  gem.version       = Vim::Flavor::VERSION

  gem.add_development_dependency('rspec', '~> 2.8')
  gem.add_development_dependency('thor', '~> 0.14.6')
end
