require 'thor'

module Vim
  module Flavor
    class CLI < Thor
      def self.common_options_to_deploy
        method_option :vimfiles_path,
          :desc => 'Where to install Vim plugins.',
          :banner => 'DIR'
        method_option :with,
          :desc => 'Deploy flavors only in comma-separated GROUPS.',
          :banner => 'GROUPS'
        method_option :without,
          :desc => 'Deploy flavors not in comma-separated GROUPS.',
          :banner => 'GROUPS'
      end

      desc 'install', 'Install Vim plugins according to VimFlavor file.'
      common_options_to_deploy
      def install
        Facade.new().install(
          options[:vimfiles_path] || default_vimfiles_path,
          normalize_groups(options[:with]),
          normalize_groups(options[:without]),
        )
      end

      desc 'upgrade', 'Upgrade Vim plugins according to VimFlavor file.'
      common_options_to_deploy
      def upgrade
        Facade.new().upgrade(
          options[:vimfiles_path] || default_vimfiles_path,
          normalize_groups(options[:with]),
          normalize_groups(options[:without])
        )
      end

      no_tasks do
        def default_vimfiles_path
          ENV['HOME'].to_vimfiles_path
        end

        def normalize_groups(s)
          groups =
            (s || '').
            split(/,/).
            map(&:strip).
            reject(&:empty?).
            map(&:to_sym)
          0 < groups.length ? groups : nil
        end
      end
    end
  end
end
