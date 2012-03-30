require 'bundler/setup'
require 'fileutils'
require 'thor'
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

    class CLI < Thor
      desc 'install', 'Install Vim plugins according to VimFlavor file.'
      method_option :vimfiles_path,
        :desc => 'A path to your vimfiles directory.'
      def install()
        facade = Facade.new()
        facade.traced = true
        facade.install(
          options[:vimfiles_path] || facade.get_default_vimfiles_path()
        )
      end

      desc 'upgrade', 'Upgrade Vim plugins according to VimFlavor file.'
      method_option :vimfiles_path,
        :desc => 'A path to your vimfiles directory.'
      def upgrade()
        facade = Facade.new()
        facade.traced = true
        facade.upgrade(
          options[:vimfiles_path] || facade.get_default_vimfiles_path()
        )
      end
    end
  end
end
