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

      desc 'update [REPO_NAME...]',
        'Update Vim plugins according to VimFlavor file.'
      common_options_to_deploy
      def update(*repo_names)
        Facade.new().update(
          options[:vimfiles_path] || default_vimfiles_path,
          repo_names
        )
      end

      desc 'upgrade [REPO_NAME...]',
        'Update Vim plugins.  (alias of "update")'
      common_options_to_deploy
      def upgrade(*repo_names)
        update(*repo_names)
      end

      desc 'test [FILES or DIRS]',
        'Run tests on a Vim plugin in the current working directory.'
      method_option :update_dependencies,
        :desc => 'Update dependencies for testing',
        :type => :boolean
      def test(*files_or_dirs)
        Facade.new().test(files_or_dirs, options)
      end

      desc 'version', 'Show the current version.'
      def version
        puts VERSION
      end

      no_tasks do
        def default_vimfiles_path
          Env::home.to_vimfiles_path
        end
      end

      def self.exit_on_failure?
        true
      end
    end
  end
end
