require 'thor'

module Vim
  module Flavor
    class CLI < Thor
      desc 'install', 'Install Vim plugins according to VimFlavor file.'
      method_option :vimfiles_path,
        :desc => 'Where to install Vim plugins.',
        :banner => 'DIR'
      def install
        Facade.new().install(
          options[:vimfiles_path] || ENV['HOME'].to_vimfiles_path
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
