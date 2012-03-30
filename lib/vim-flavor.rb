require 'bundler/setup'
require 'fileutils'
require 'thor'
require 'vim-flavor/flavor'
require 'vim-flavor/flavorfile'
require 'vim-flavor/lockfile'
require 'vim-flavor/stringextension'
require 'vim-flavor/version'
require 'vim-flavor/versionconstraint'
require 'yaml'

module Vim
  module Flavor
    class << self
      @@dot_path = File.expand_path('~/.vim-flavor')

      def dot_path
        @@dot_path
      end

      def dot_path= path
        @@dot_path = path
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

      def create_vim_script_for_bootstrap(vimfiles_path)
        bootstrap_path = "#{vimfiles_path.to_flavors_path()}/bootstrap.vim"
        FileUtils.mkdir_p(File.dirname(bootstrap_path))
        File.open(bootstrap_path, 'w') do |f|
          f.write(<<-'END')
            function! s:bootstrap()
              let current_rtp = &runtimepath
              let current_rtps = split(current_rtp, ',')
              set runtimepath&
              let default_rtp = &runtimepath
              let default_rtps = split(default_rtp, ',')
              let user_dir = default_rtps[0]
              let user_after_dir = default_rtps[-1]
              let base_rtps =
              \ filter(copy(current_rtps),
              \        'v:val !=# user_dir && v:val !=# user_after_dir')
              let flavor_dirs =
              \ filter(split(glob(user_dir . '/flavors/*'), '\n'),
              \        'isdirectory(v:val)')
              let new_rtps =
              \ []
              \ + [user_dir]
              \ + flavor_dirs
              \ + base_rtps
              \ + map(reverse(copy(flavor_dirs)), 'v:val . "/after"')
              \ + [user_after_dir]
              let &runtimepath = join(new_rtps, ',')
            endfunction

            call s:bootstrap()
          END
        end
      end

      def deploy_flavors(flavor_list, vimfiles_path)
        FileUtils.rm_rf(
          ["#{vimfiles_path.to_flavors_path()}"],
          :secure => true
        )

        create_vim_script_for_bootstrap(vimfiles_path)
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
