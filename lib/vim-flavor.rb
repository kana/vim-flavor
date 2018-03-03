require 'vim-flavor/enumerableextension'

module Vim
  module Flavor
    [
      :BranchVersion,
      :CLI,
      :Console,
      :Env,
      :Facade,
      :Flavor,
      :FlavorFile,
      :LockFile,
      :LockFileParser,
      :PlainVersion,
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
