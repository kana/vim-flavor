module Vim
  module Flavor
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
