require 'bundler/setup'
require 'fileutils'
require 'thor'
require 'vim-flavor/cli'
require 'vim-flavor/facade'
require 'vim-flavor/flavor'
require 'vim-flavor/flavorfile'
require 'vim-flavor/lockfile'
require 'vim-flavor/stringextension'
require 'vim-flavor/version'
require 'vim-flavor/versionconstraint'
require 'yaml'

module Vim
  module Flavor
    class << self
      @@dot_path = File.expand_path('~/.vim-flavor')

      def dot_path
        @@dot_path
      end

      def dot_path= path
        @@dot_path = path
      end
    end
  end
end
