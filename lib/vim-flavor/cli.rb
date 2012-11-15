require 'thor'

module Vim
  module Flavor
    class CLI < Thor
      desc 'install', 'Install Vim plugins according to VimFlavor file.'
      def install
        Facade.new().install(ENV['HOME'].to_vimfiles_path)
      end
    end
  end
end
