module Vim
  module Flavor
    class Flavor
      @@properties = [
        :groups,
        :locked_version,
        :repo_name,
        :repo_uri,
        :version_contraint,
      ]

      @@properties.each do |p|
        attr_accessor p
      end

      def initialize()
        @groups = []
      end

      def ==(other)
        return false if self.class != other.class
        @@properties.all? do |p|
          self.send(p) == other.send(p)
        end
      end

      def zapped_repo_dir_name
        @repo_name.gsub(/[^A-Za-z0-9._-]/, '_')
      end

      def cached_repo_path
        @cached_repo_path ||=
          "#{Vim::Flavor.dot_path}/repos/#{zapped_repo_dir_name}"
      end

      def make_deploy_path(vimfiles_path)
        "#{vimfiles_path.to_flavors_path()}/#{zapped_repo_dir_name}"
      end

      def clone()
        message = %x[
          {
            git clone '#{@repo_uri}' '#{cached_repo_path}'
          } 2>&1
        ]
        if $? != 0
          raise RuntimeError, message
        end
        true
      end

      def fetch()
        message = %x[
          {
            cd #{cached_repo_path.inspect} &&
            git fetch origin
          } 2>&1
        ]
        if $? != 0
          raise RuntimeError, message
        end
      end

      def deploy(vimfiles_path)
        deploy_path = make_deploy_path(vimfiles_path)
        message = %x[
          {
            cd '#{cached_repo_path}' &&
            git checkout -f '#{locked_version}' &&
            git checkout-index -a -f --prefix='#{deploy_path}/' &&
            {
              vim -u NONE -i NONE -n -N -e -s -c '
                silent! helptags #{deploy_path}/doc
                qall!
              ' || true
            }
          } 2>&1
        ]
        if $? != 0
          raise RuntimeError, message
        end
      end

      def undeploy(vimfiles_path)
        deploy_path = make_deploy_path(vimfiles_path)
        message = %x[
          {
            rm -fr '#{deploy_path}'
          } 2>&1
        ]
        if $? != 0
          raise RuntimeError, message
        end
      end

      def list_versions()
        tags = %x[
          {
            cd '#{cached_repo_path}' &&
            git tag
          } 2>&1
        ]
        if $? != 0
          raise RuntimeError, message
        end

        tags.
          split(/[\r\n]/).
          select {|t| t != '' && Gem::Version.correct?(t)}.
          map {|t| Gem::Version.create(t)}
      end

      def update_locked_version()
        @locked_version =
          version_contraint.find_the_best_version(list_versions())
      end
    end
  end
end
