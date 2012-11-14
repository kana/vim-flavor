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
  end
end
