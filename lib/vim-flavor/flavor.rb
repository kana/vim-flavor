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

      # Return true if this flavor's repository is already cloned.
      def cached?
        Dir.exists?(cached_repo_path)
      end

      def cached_repo_path
        @cached_repo_path ||=
          "#{ENV['HOME'].to_vimfiles_path}/repos/#{@repo_name.zap}"
      end

      def repo_uri
        @repo_uri ||=
          if /^([^\/]+)$/.match(repo_name)
            m = Regexp.last_match
            "git://github.com/vim-scripts/#{m[1]}.git"
          elsif /^([A-Za-z0-9_-]+)\/(.*)$/.match(repo_name)
            m = Regexp.last_match
            "git://github.com/#{m[1]}/#{m[2]}.git"
          elsif /^[a-z]+:\/\/.*$/.match(repo_name)
            repo_name
          else
            raise "Invalid repo_name: #{repo_name.inspect}"
          end
      end

      def clone()
        sh %Q[
          {
            git clone '#{repo_uri}' '#{cached_repo_path}'
          } 2>&1
        ]
        true
      end

      def deploy(vimfiles_path)
        deployment_path = "#{vimfiles_path.to_flavors_path}/#{repo_name.zap}"
        sh %Q[
          {
            cd '#{cached_repo_path}' &&
            git checkout -f '#{locked_version}' &&
            git checkout-index -a -f --prefix='#{deployment_path}/' &&
            {
              vim -u NONE -i NONE -n -N -e -s -c '
                silent! helptags #{deployment_path}/doc
                qall!
              ' || true
            }
          } 2>&1
        ]
        true
      end

      def use_appropriate_version()
        @locked_version =
          version_constraint.find_the_best_version(list_versions)
      end

      def list_versions()
        tags = sh %Q[
          {
            cd '#{cached_repo_path}' &&
            git tag
          } 2>&1
        ]

        tags.
          split(/[\r\n]/).
          select {|t| t != '' && Gem::Version.correct?(t)}.
          map {|t| Gem::Version.create(t)}
      end

      def sh script
        output = send(:`, script)
        if $? == 0
          output
        else
          raise RuntimeError, output
        end
      end

      def satisfied_with?(locked_flavor)
        repo_name == locked_flavor.repo_name &&
          version_constraint.compatible?(locked_flavor.locked_version)
      end
    end
  end
end
