module Vim
  module Flavor
    class Env
      class << self
        def github_uri_prefix
          @github_uri_prefix ||=
            ENV['VIM_FLAVOR_GITHUB_URI_PREFIX'] ||
            'git://github.com/'
        end
      end
    end
  end
end

