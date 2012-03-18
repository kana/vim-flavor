require 'bundler/setup'
require 'thor'
require 'vim-flavor/version'
require 'yaml'

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

      def zapped_repo_dir_name
        @repo_name.gsub(/[^A-Za-z0-9._-]/, '_')
      end

      def cached_repo_path
        @cached_repo_path ||=
          "#{CACHED_REPOS_PATH}/#{zapped_repo_dir_name}"
      end

      def make_deploy_path(vimfiles_path)
        "#{vimfiles_path}/flavors/#{zapped_repo_dir_name}"
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

      def deploy(vimfiles_path)
        deploy_path = make_deploy_path(vimfiles_path)
        message = %x[
          {
            cd '#{cached_repo_path}' &&
            git checkout -f #{locked_version.inspect} &&
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

    class LockFile
      # TODO: Resolve dependencies recursively.

      attr_reader :flavors, :path

      def initialize(path)
        @flavors = {}  # repo_uri => flavor
        @path = path
      end

      def load()
        h = File.open(@path, 'rb') do |f|
          YAML.load(f.read())
        end

        @flavors = self.class.flavors_from_poro(h[:flavors])
      end

      def save()
        h = {}

        h[:flavors] = self.class.poro_from_flavors(@flavors)

        File.open(@path, 'wb') do |f|
          YAML.dump(h, f)
        end
      end

      def self.poro_from_flavors(flavors)
        # TODO: Implement to hide implementation details from lock files.
        flavors
      end

      def self.flavors_from_poro(poro)
        # TODO: Implement to hide implementation details from lock files.
        poro
      end
    end

    class Facade
      attr_reader :flavorfile
      attr_accessor :flavorfile_path
      attr_reader :lockfile
      attr_accessor :lockfile_path
      attr_accessor :traced

      def initialize()
        @flavorfile = nil  # FlavorFile
        @flavorfile_path = "#{Dir.getwd()}/VimFlavor"
        @lockfile = nil  # LockFile
        @lockfile_path = "#{Dir.getwd()}/VimFlavor.lock"
        @traced = false
      end

      def trace(message)
        print(message) if @traced
      end

      def load()
        @flavorfile = FlavorFile.new()
        @flavorfile.eval_flavorfile(@flavorfile_path)

        @lockfile = LockFile.new(@lockfile_path)
        @lockfile.load() if File.exists?(@lockfile_path)
      end

      def make_new_flavors(current_flavors, locked_flavors, mode)
        new_flavors = {}

        current_flavors.each do |repo_uri, cf|
          lf = locked_flavors[repo_uri]
          nf = cf.dup()

          nf.locked_version =
            if (not lf) or
              cf.version_contraint != lf.version_contraint or
              mode == :update then
              cf.locked_version
            else
              lf.locked_version
            end

          new_flavors[repo_uri] = nf
        end

        new_flavors
      end

      def deploy_flavors(flavor_list, vimfiles_path)
        # FIXME: Unify the way to get the flavors directory.
        FileUtils.rm_rf(["#{vimfiles_path}/flavors"], :secure => true)
        flavor_list.each do |f|
          trace("Deploying #{f.repo_name} (#{f.locked_version})\n")
          f.deploy(vimfiles_path)
        end
      end

      def save_lockfile()
        @lockfile.save()
      end

      def complete_locked_flavors(mode)
        nfs = {}
        @flavorfile.flavors.each do |repo_uri, cf|
          nf = cf.dup()
          lf = @lockfile.flavors[repo_uri]

          trace("Using #{nf.repo_name} ... ")
          begin
            if not File.exists?(nf.cached_repo_path)
              nf.clone()
            end

            if mode == :upgrade_all or
              (not lf) or
              nf.version_contraint != lf.version_contraint then
              nf.fetch()
              nf.update_locked_version()
            else
              nf.locked_version = lf.locked_version
            end
          end
          trace("(#{nf.locked_version})\n")

          nfs[repo_uri] = nf
        end

        @lockfile.instance_eval do
          @flavors = nfs
        end
      end

      def get_default_vimfiles_path()
        # FIXME: Compute more appropriate value.
        "#{ENV['HOME']}/.vim"
      end

      def install(vimfiles_path)
        load()
        complete_locked_flavors(:upgrade_if_necessary)
        save_lockfile()
        deploy_flavors(lockfile.flavors.values, vimfiles_path)
      end

      def upgrade(vimfiles_path)
        load()
        complete_locked_flavors(:upgrade_all)
        save_lockfile()
        deploy_flavors(lockfile.flavors.values, vimfiles_path)
      end
    end

    class CLI < Thor
      desc 'install', 'Install Vim plugins according to VimFlavor file.'
      method_option :vimfiles_path,
        :desc => 'A path to your vimfiles directory.'
      def install()
        facade = Facade.new()
        facade.traced = true
        facade.install(
          options[:vimfiles_path] || facade.get_default_vimfiles_path()
        )
      end

      desc 'upgrade', 'Upgrade Vim plugins according to VimFlavor file.'
      method_option :vimfiles_path,
        :desc => 'A path to your vimfiles directory.'
      def upgrade()
        facade = Facade.new()
        facade.traced = true
        facade.upgrade(
          options[:vimfiles_path] || facade.get_default_vimfiles_path()
        )
      end
    end
  end
end
