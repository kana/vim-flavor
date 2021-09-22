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
  spec.required_ruby_version = '~> 3.0'

  spec.add_dependency('parslet', '>= 1.8', '< 3.0')
  spec.add_dependency('pastel', '~> 0.7')
  spec.add_dependency('thor', '>= 0.20', '< 2.0')

  spec.add_development_dependency('aruba', '~> 0.14')
  spec.add_development_dependency('cucumber', '~> 7.0')
  spec.add_development_dependency('pry')
  spec.add_development_dependency('relish', '~> 0.7')
  spec.add_development_dependency('rspec', '~> 3.7')
end
