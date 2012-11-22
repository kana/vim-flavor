require 'thor'

module Vim
  module Flavor
    class CLI < Thor
      def self.common_options_to_deploy
        method_option :vimfiles_path,
          :desc => 'Where to install Vim plugins.',
          :banner => 'DIR'
      end

      desc 'install', 'Install Vim plugins according to VimFlavor file.'
      common_options_to_deploy
      def install
        Facade.new().install(
          options[:vimfiles_path] || default_vimfiles_path
        )
      end

      desc 'upgrade', 'Upgrade Vim plugins according to VimFlavor file.'
      common_options_to_deploy
      def upgrade
        Facade.new().upgrade(
          options[:vimfiles_path] || default_vimfiles_path
        )
      end

      no_tasks do
        def default_vimfiles_path
          ENV['HOME'].to_vimfiles_path
        end
      end
    end
  end
end
