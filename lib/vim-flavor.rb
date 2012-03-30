require 'bundler/setup'

module Vim
  module Flavor
    [
      :CLI,
      :Facade,
      :Flavor,
      :FlavorFile,
      :LockFile,
      :StringExtension,
      :VERSION,
      :VersionConstraint,
    ].each do |name|
      autoload name, "vim-flavor/#{name.to_s().downcase()}"
    end

    class ::String
      include StringExtension
    end

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
