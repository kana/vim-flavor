require 'fileutils'

module Vim
  module Flavor
    class Facade
      def refresh_flavors(mode, vimfiles_path)
        flavorfile = FlavorFile.load(Dir.getwd().to_flavorfile_path)
        lockfile = LockFile.load_or_new(Dir.getwd().to_lockfile_path)

        lockfile.update(
          complete(
            flavorfile.flavor_table,
            lockfile.flavor_table,
            mode
          )
        )
        lockfile.save()

        deploy_flavors(lockfile.flavors, vimfiles_path)
      end

      def install(vimfiles_path)
        refresh_flavors(:install, vimfiles_path)
      end

      def upgrade(vimfiles_path)
        refresh_flavors(:upgrade, vimfiles_path)
      end

      def complete(current_flavor_table, locked_flavor_table, mode)
        completed_flavor_table = {}

        current_flavor_table.each do |repo_name, cf|
          nf = cf.dup()
          lf = locked_flavor_table[repo_name]

          already_cached = nf.cached?
          nf.clone() unless already_cached

          if mode == :install and lf and nf.satisfied_with?(lf)
            nf.use_specific_version(lf.locked_version)
          else
            nf.fetch() if already_cached
            nf.use_appropriate_version()
          end

          completed_flavor_table[repo_name] = nf
        end

        completed_flavor_table
      end

      def deploy_flavors(flavors, vimfiles_path)
        FileUtils.rm_rf(
          ["#{vimfiles_path.to_flavors_path}"],
          :secure => true
        )

        create_vim_script_for_bootstrap(vimfiles_path)
        flavors.each do |f|
          f.deploy(vimfiles_path)
        end
      end

      def create_vim_script_for_bootstrap(vimfiles_path)
        bootstrap_path = vimfiles_path.to_flavors_path.to_bootstrap_path
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
    end
  end
end

