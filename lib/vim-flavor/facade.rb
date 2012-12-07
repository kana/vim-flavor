require 'fileutils'

module Vim
  module Flavor
    class Facade
      include ShellUtility

      def trace message
        print message
      end

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

        deploy_flavors(
          lockfile.flavors.select {|f| f.group == :runtime},
          File.absolute_path(vimfiles_path).to_flavors_path
        )

        trace "Completed.\n"
      end

      def install(vimfiles_path)
        refresh_flavors(:install, vimfiles_path)
      end

      def upgrade(vimfiles_path)
        refresh_flavors(:upgrade, vimfiles_path)
      end

      def complete(current_flavor_table, locked_flavor_table, mode)
        completed_flavor_table = {}

        trace "Checking versions...\n"

        current_flavor_table.values.map(&:dup).sort_by(&:repo_name).
        before_each {|nf| trace "  Use #{nf.repo_name} ..."}.
        after_each {|nf| trace " #{nf.locked_version}\n"}.
        on_failure {trace " failed\n"}.
        each do |nf|
          lf = locked_flavor_table[nf.repo_name]

          already_cached = nf.cached?
          nf.clone() unless already_cached

          if mode == :install and lf and nf.satisfied_with?(lf)
            if not nf.cached_version?(lf.locked_version)
              nf.fetch()
              if not nf.cached_version?(lf.locked_version)
                raise RuntimeError, "#{nf.repo_name} is locked to #{lf.locked_version}, but no such version exists"
              end
            end
            nf.use_specific_version(lf.locked_version)
          else
            nf.fetch() if already_cached
            nf.use_appropriate_version()
          end

          completed_flavor_table[nf.repo_name] = nf
        end

        completed_flavor_table
      end

      def deploy_flavors(flavors, flavors_path)
        trace "Deploying plugins...\n"

        a_flavors_path = File.absolute_path(flavors_path)

        FileUtils.rm_rf(
          [a_flavors_path],
          :secure => true
        )
        old_lockfile = LockFile.load_or_new(a_flavors_path.to_lockfile_path)

        create_vim_script_for_bootstrap(a_flavors_path)

        flavors.
        before_each {|f| trace "  #{f.repo_name} #{f.locked_version} ..."}.
        after_each {|f| trace " done\n"}.
        on_failure {trace " failed\n"}.
        each do |f|
          f.deploy(a_flavors_path)
        end

        old_lockfile.flavors = flavors
        old_lockfile.save()
      end

      def create_vim_script_for_bootstrap(flavors_path)
        bootstrap_path = flavors_path.to_bootstrap_path
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

      def test()
        trace "-------- Preparing dependencies\n"

        flavorfile = FlavorFile.load_or_new(Dir.getwd().to_flavorfile_path)
        flavorfile.flavor 'kana/vim-vspec', '~> 1.0', :group => :development unless
          flavorfile.flavor_table.has_key?('kana/vim-vspec')
        lockfile = LockFile.load_or_new(Dir.getwd().to_lockfile_path)

        lockfile.update(
          complete(
            flavorfile.flavor_table,
            lockfile.flavor_table,
            :install
          )
        )
        lockfile.save()

        # FIXME: It's somewhat wasteful to refresh flavors every time.
        deploy_flavors(
          lockfile.flavors,
          Dir.getwd().to_stash_path.to_deps_path
        )

        trace "-------- Testing a Vim plugin\n"

        prove_options = '--comments --failure --directives'
        deps_path = Dir.getwd().to_stash_path.to_deps_path
        vspec = "#{deps_path}/#{'kana/vim-vspec'.zap}/bin/vspec"
        plugin_paths = lockfile.flavors.map {|f|
          "#{deps_path}/#{f.repo_name.zap}"
        }
        succeeded = system %Q{
          prove --ext '.t' #{prove_options} &&
          prove --ext '.vim' #{prove_options} \
            --exec '#{vspec} #{Dir.getwd()} #{plugin_paths.join(' ')}'
        }
        exit(1) unless succeeded
      end
    end
  end
end

