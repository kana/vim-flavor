module Vim
  module Flavor
    class Env
      class << self
        def home
          @home ||=
            ENV['VIM_FLAVOR_HOME'] ||
            ENV['HOME']
        end

        def github_uri_prefix
          @github_uri_prefix ||=
            ENV['VIM_FLAVOR_GITHUB_URI_PREFIX'] ||
            'git://github.com/'
        end

        def github_uri_suffix
          @github_uri_suffix ||=
            ENV['VIM_FLAVOR_GITHUB_URI_SUFFIX'] ||
            '.git'
        end
      end
    end
  end
end

