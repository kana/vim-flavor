module Vim
  module Flavor
    module StringExtension
      def to_bootstrap_path
        "#{self}/bootstrap.vim"
      end

      def to_deps_path
        "#{self}/deps"
      end

      def to_flavorfile_path
        "#{self}/VimFlavor"
      end

      def to_flavors_path
        "#{self}/flavors"
      end

      def to_lockfile_path
        "#{self}/VimFlavor.lock"
      end

      def to_stash_path
        "#{self}/.vim-flavor"
      end

      def to_vimfiles_path
        "#{self}/.vim"
      end

      def zap
        gsub(/[^A-Za-z0-9._-]/, '_')
      end
    end
  end
end
