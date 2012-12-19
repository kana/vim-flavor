require 'fileutils'

module Vim
  module Flavor
    class Facade
      include ShellUtility

      def trace message
        print message
      end

      def refresh_flavors(mode, flavorfile, lockfile, groups, flavors_path)
        lockfile.update(
          complete(
            flavorfile.flavor_table,
            lockfile.flavor_table,
            mode
          )
        )
        lockfile.save()

        deploy_flavors(
          lockfile.flavors.select {|f| groups.include?(f.group)},
          File.absolute_path(flavors_path)
        )

        trace "Completed.\n"
      end

      def install_or_upgrade(mode, vimfiles_path)
        flavorfile = FlavorFile.load(Dir.getwd().to_flavorfile_path)
        lockfile = LockFile.load_or_new(Dir.getwd().to_lockfile_path)
        refresh_flavors(
          mode,
          flavorfile,
          lockfile,
          [:runtime],
          vimfiles_path.to_flavors_path
        )
      end

      def install(vimfiles_path)
        install_or_upgrade(:install, vimfiles_path)
      end

      def upgrade(vimfiles_path)
        install_or_upgrade(:upgrade, vimfiles_path)
      end

      def complete(current_flavor_table, locked_flavor_table, mode)
        trace "Checking versions...\n"

        nfs =
          current_flavor_table.values.map(&:dup).sort_by(&:repo_name).
          before_each {|nf| trace "  Use #{nf.repo_name} ..."}.
          after_each {|nf| trace " #{nf.locked_version}\n"}.
          on_failure {trace " failed\n"}.
          map {|nf|
            lf = locked_flavor_table[nf.repo_name]
            complete_a_flavor(nf, lf, mode)
            nf
          }

        Hash[nfs.map {|nf| [nf.repo_name, nf]}]
      end

      def complete_a_flavor(nf, lf, mode)
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
      end

      def deploy_flavors(flavors, flavors_path)
        trace "Deploying plugins...\n"

        a_flavors_path = File.absolute_path(flavors_path)
        deployment_memo = LockFile.load_or_new(a_flavors_path.to_lockfile_path)

        # To uninstall flavors which were deployed by vim-flavor 1.0.2 or
        # older, the whole deployed flavors have to be removed.  Because
        # deployment_memo is recorded since 1.0.3.
        FileUtils.rm_rf(
          [a_flavors_path],
          :secure => true
        ) if deployment_memo.flavors.empty?

        create_vim_script_for_bootstrap(a_flavors_path)

        flavors.
        before_each {|f| trace "  #{f.repo_name} #{f.locked_version} ..."}.
        on_failure {trace " failed\n"}.
        each do |f|
          df = deployment_memo.flavor_table[f.repo_name]
          deployed_version = (df and df.locked_version)
          if f.locked_version == deployed_version
            trace " skipped (already deployed)\n"
          else
            FileUtils.rm_rf(
              [f.make_deployment_path(a_flavors_path)],
              :secure => true
            )
            f.deploy(a_flavors_path)
            trace " done\n"
          end
        end

        deployment_memo.flavors.each do |df|
          if flavors.all? {|f| f.repo_name != df.repo_name}
            trace "  #{df.repo_name} ..."
            FileUtils.rm_rf(
              [df.make_deployment_path(a_flavors_path)],
              :secure => true
            )
            trace " uninstalled\n"
          end
        end

        deployment_memo.flavors = flavors
        deployment_memo.save()
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

