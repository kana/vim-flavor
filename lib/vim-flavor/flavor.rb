module Vim
  module Flavor
    class Flavor
      # A short name of a repository.
      # Possible formats are "$user/$repo", "$repo" and "$repo_uri".
      attr_accessor :repo_name

      # A constraint to choose a proper version.
      attr_accessor :version_constraint

      # A version of a plugin to be installed.
      attr_accessor :locked_version
    end
  end
end
