require 'bundler/setup'
require 'vim-flavor/version'

module Vim
  module Flavor
    class VersionConstraint
      attr_reader :base_version, :operator

      def initialize(s)
        @base_version, @operator = parse(s)
      end

      def ==(other)
        self.base_version == other.base_version &&
          self.operator == other.operator
      end

      def parse(s)
        m = /^\s*(>=|~>)\s+(\S+)$/.match(s)
        if m then
          [Gem::Version.create(m[2]), m[1]]
        else
          raise "Invalid version constraint: #{s.inspect}"
        end
      end

      def compatible?(other_version_or_s)
        v = Gem::Version.create(other_version_or_s)
        if @operator == '~>' then
          self.base_version.bump() > v and v >= self.base_version
        elsif @operator == '>=' then
          v >= self.base_version
        else
          raise NotImplementedError
        end
      end

      def find_the_best_version(versions)
        versions.
          select {|v| compatible?(v)}.
          sort().
          reverse().
          first
      end
    end

    DOT_PATH = "#{Dir.getwd()}/.vim-flavor"
    CACHED_REPOS_PATH = "#{DOT_PATH}/repos"

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
        @@properties.all? do |p|
          self.send(p) == other.send(p)
        end
      end

      def zapped_repo_uri
        repo_uri.gsub(/[^A-Za-z0-9._-]/, '_')
      end

      def cached_repo_path
        @cached_repo_path ||=
          "#{CACHED_REPOS_PATH}/#{zapped_repo_uri}"
      end

      def make_deploy_path(vimfiles_path)
        "#{vimfiles_path}/flavors/#{zapped_repo_uri}"
      end

      def clone()
        message = %x[
          {
            git clone '#{@repo_uri}' '#{cached_repo_path}'
          } 2>&1
        ]
        if $? != 0 then
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
        if $? != 0 then
          raise RuntimeError, message
        end
      end

      def checkout()
        message = %x[
          {
            cd #{cached_repo_path.inspect} &&
            git checkout -f #{locked_version.inspect}
          } 2>&1
        ]
        if $? != 0 then
          raise RuntimeError, message
        end
      end

      def deploy(vimfiles_path)
        deploy_path = make_deploy_path(vimfiles_path)
        message = %x[
          {
            cd '#{cached_repo_path}' &&
            git checkout-index -a -f --prefix='#{deploy_path}/' &&
            vim -u NONE -i NONE -n -N -e -c 'helptags #{deploy_path}/doc | qall!'
          } 2>&1
        ]
        if $? != 0 then
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
        if $? != 0 then
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
        if $? != 0 then
          raise RuntimeError, message
        end

        tags.
          split(/[\r\n]/).
          select {|t| t != ''}.
          map {|t| Gem::Version.create(t)}
      end

      def update_locked_version()
        @locked_version =
          version_contraint.find_the_best_version(list_versions())
      end
    end

    class FlavorFile
      attr_reader :flavors

      def initialize()
        @flavors = {}
        @default_groups = [:default]
      end

      def interpret(&block)
        instance_eval(&block)
      end

      def eval_flavorfile(flavorfile_path)
        content = File.open(flavorfile_path, 'rb') do |f|
          f.read()
        end
        interpret do
          instance_eval(content)
        end
      end

      def repo_uri_from_repo_name(repo_name)
        if /^([^\/]+)$/.match(repo_name) then
          m = Regexp.last_match
          "git://github.com/vim-scripts/#{m[1]}.git"
        elsif /^([A-Za-z0-9_-]+)\/(.*)$/.match(repo_name) then
          m = Regexp.last_match
          "git://github.com/#{m[1]}/#{m[2]}.git"
        elsif /^[a-z]+:\/\/.*$/.match(repo_name) then
          repo_name
        else
          raise "repo_name is written in invalid format: #{repo_name.inspect}"
        end
      end

      def flavor(repo_name, *args)
        options = Hash === args.last ? args.pop : {}
        options[:groups] ||= []
        version_contraint = VersionConstraint.new(args.last || '>= 0')

        f = Flavor.new()
        f.repo_name = repo_name
        f.repo_uri = repo_uri_from_repo_name(repo_name)
        f.version_contraint = version_contraint
        f.groups = @default_groups + options[:groups]

        @flavors[f.repo_uri] = f
      end

      def group(*group_names, &block)
        @default_groups.concat(group_names)
        yield
      ensure
        group_names.each do
          @default_groups.pop()
        end
      end
    end
  end
end
