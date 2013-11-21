require 'bundler/setup'
require 'vim-flavor/enumerableextension'

module Vim
  module Flavor
    [
      :CLI,
      :Env,
      :Facade,
      :Flavor,
      :FlavorFile,
      :LockFile,
      :LockFileParser,
      :ShellUtility,
      :StringExtension,
      :VERSION,
      :Version,
      :VersionConstraint,
    ].each do |name|
      autoload name, "vim-flavor/#{name.to_s().downcase()}"
    end

    class ::String
      include StringExtension
    end
  end
end
