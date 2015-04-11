# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vim-flavor/version'

Gem::Specification.new do |spec|
  spec.name          = 'vim-flavor'
  spec.version       = Vim::Flavor::VERSION
  spec.authors       = ['Kana Natsuno']
  spec.email         = ['dev@whileimautomaton.net']
  spec.summary       = %q{A tool to manage your favorite Vim plugins}
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/kana/vim-flavor'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency('parslet', '~> 1.7')
  spec.add_dependency('thor', '~> 0.19')

  spec.add_development_dependency('aruba', '~> 0.6')
  spec.add_development_dependency('cucumber', '~> 1.3')
  spec.add_development_dependency('pry')
  spec.add_development_dependency('rspec', '~> 2.99')
end
