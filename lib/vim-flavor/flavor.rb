module Vim
  module Flavor
    class Flavor
      include ShellUtility

      # A short name of a repository.
      # Possible formats are "$user/$repo", "$repo" and "$repo_uri".
      attr_accessor :repo_name

      # A constraint to choose a proper version.
      attr_accessor :version_constraint

      # A group which this flavor belongs to.
      attr_accessor :group

      # A version of a plugin to be installed.
      attr_accessor :locked_version

      # repo_name of a flavor which requires this flavor.
      attr_accessor :requirer

      # Return true if this flavor's repository is already cloned.
      def cached?
        Dir.exists?(cached_repo_path)
      end

      def cached_version?(version)
        system <<-"END"
          {
            cd '#{cached_repo_path}' &&
            git rev-list --quiet '#{version.to_revision}' --
          } >/dev/null 2>&1
        END
      end

      def cached_repo_path
        @cached_repo_path ||=
          "#{Env::home.to_stash_path}/repos/#{@repo_name.zap}"
      end

      def make_deployment_path(flavors_path)
        "#{flavors_path}/#{repo_name.zap}"
      end

      def self.github_repo_uri(user, repo)
        "#{Env::github_uri_prefix}#{user}/#{repo}#{Env::github_uri_suffix}"
      end

      def repo_uri
        @repo_uri ||=
          if /^([^\/]+)$/.match(repo_name)
            m = Regexp.last_match
            self.class.github_repo_uri('vim-scripts', m[1])
          elsif /^([A-Za-z0-9_-]+)\/(.*)$/.match(repo_name)
            m = Regexp.last_match
            self.class.github_repo_uri(m[1], m[2])
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

      def fetch()
        sh %Q{
          {
            cd '#{cached_repo_path}' &&
            git fetch origin --tags '+refs/heads/*:refs/remotes/origin/*'
          } 2>&1
        }
      end

      def checkout()
        sh %Q[
          {
            cd '#{cached_repo_path}' &&
            git checkout -f '#{locked_version.to_revision}'
          } 2>&1
        ]
      end

      def deploy(flavors_path)
        deployment_path = make_deployment_path(flavors_path)
        sh %Q[
          {
            cd '#{cached_repo_path}' &&
            git checkout -f '#{locked_version.to_revision}' &&
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
          case
          when PlainVersion === version_constraint.base_version
            version_constraint.find_the_best_version(list_versions)
          when BranchVersion === version_constraint.base_version
            make_branch_version(version_constraint.base_version.branch)
          else
            throw "Unexpected version_constraint: #{version_constraint}"
          end
      end

      def use_specific_version(locked_version)
        @locked_version = locked_version
      end

      def list_tags()
        output = sh %Q[
          {
            cd '#{cached_repo_path}' &&
            git tag
          } 2>&1
        ]
        output.split(/[\r\n]/)
      end

      def versions_from_tags(tags)
        tags.
          select {|t| t != '' && Version.correct?(t)}.
          map {|t| Version.create(t)}
      end

      def list_versions()
        versions_from_tags(list_tags())
      end

      def satisfied_with?(version)
        version_constraint.compatible?(version)
      end

      def make_branch_version(branch)
        revision = sh(%Q[
          cd '#{cached_repo_path}' &&
          git rev-list -n1 'origin/#{branch}' --
        ]).chomp
        BranchVersion.new(branch, revision)
      end
    end
  end
end
