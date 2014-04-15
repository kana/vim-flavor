require 'fileutils'
require 'shellwords'

module Vim
  module Flavor
    class Facade
      def install(vimfiles_path)
        install_or_update(:install, vimfiles_path)
      end

      def update(vimfiles_path)
        install_or_update(:update, vimfiles_path)
      end

      def test(files_or_dirs)
        trace "-------- Preparing dependencies\n"

        flavorfile = FlavorFile.load_or_new(Dir.getwd().to_flavorfile_path)
        flavorfile.flavor 'kana/vim-vspec', '~> 1.0', :group => :development unless
          flavorfile.flavor_table.has_key?('kana/vim-vspec')
        lockfile = LockFile.load_or_new(Dir.getwd().to_lockfile_path)

        refresh_flavors(
          :install,
          flavorfile,
          lockfile,
          [:runtime, :development],
          Dir.getwd().to_stash_path.to_deps_path
        )

        trace "-------- Testing a Vim plugin\n"

        prove_options = '--comments --failure --directives'
        deps_path = Dir.getwd().to_stash_path.to_deps_path
        vspec = "#{deps_path}/#{'kana/vim-vspec'.zap}/bin/vspec"
        plugin_paths = lockfile.flavors.map {|f|
          "#{deps_path}/#{f.repo_name.zap}"
        }
        dirs = files_or_dirs.select {|p| File.directory?(p)}
        t_files = files_or_dirs.select {|p| File.file?(p) &&
                                            File.extname(p) == '.t'}
        vim_files = files_or_dirs.select {|p| File.file?(p) &&
                                              File.extname(p) == '.vim'}
        commands = []
        commands <<
          %Q{ prove --ext '.t' #{prove_options} \
                #{(dirs + t_files).shelljoin} } if files_or_dirs.none? or
                                                   dirs.any? or t_files.any?
        commands <<
          %Q{ prove --ext '.vim' #{prove_options} \
                --exec '#{vspec} #{Dir.getwd()} #{plugin_paths.join(' ')}' \
                #{(dirs + vim_files).shelljoin} } if files_or_dirs.none? or
                                                     dirs.any? or vim_files.any?
        succeeded = system(commands.join('&&'))
        exit(1) unless succeeded
      end

      def install_or_update(mode, vimfiles_path)
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

      def refresh_flavors(mode, flavorfile, lockfile, groups, flavors_path)
        trace "Checking versions...\n"

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

      def complete(current_flavor_table, locked_flavor_table, mode, level = 1)
        nfs = complete_flavors(current_flavor_table, locked_flavor_table, mode, level, 'you')

        Hash[
          nfs.group_by {|nf| nf.repo_name}.map {|repo_name, nfg|
            [repo_name, choose_a_flavor(nfg)]
          }
        ]
      end

      def choose_a_flavor(nfg)
        vs = nfg.map {|nf| nf.locked_version}.uniq
        if vs.length == 1
          nfg.first
        else
          lv = find_latest_version(vs)
          if lv and nfg.all? {|nf| nf.satisfied_with?(lv)}
            nf = nfg.first
            nf.use_specific_version(lv)
            nf
          else
            stop_by_incompatible_declarations(nfg)
          end
        end
      end

      def find_latest_version(vs)
        vs.all? {|v| PlainVersion === v} and vs.max() or nil
      end

      def stop_by_incompatible_declarations(nfg)
        ss = []
        ss << 'Found incompatible declarations:'
        nfg.each do |nf|
          ss << "  #{nf.repo_name} #{nf.version_constraint} is required by #{nf.requirer}"
        end
        ss << 'Please resolve the conflict.'
        abort ss.join("\n")
      end

      def complete_flavors(current_flavor_table, locked_flavor_table, mode, level, requirer)
        current_flavor_table.values.map(&:dup).sort_by(&:repo_name).
        on_failure {trace " failed\n"}.
        flat_map {|nf|
          complete_a_flavor(nf, locked_flavor_table, mode, level, requirer)
        }
      end

      def complete_a_flavor(nf, locked_flavor_table, mode, level, requirer)
        lf = locked_flavor_table[nf.repo_name]
        [complete_a_flavor_itself(nf, lf, mode, level, requirer)] +
          complete_a_flavor_dependencies(nf, locked_flavor_table, mode, level)
      end

      def complete_a_flavor_itself(nf, lf, mode, level, requirer)
        trace "#{'  ' * level}Use #{nf.repo_name} ..."

        already_cached = nf.cached?
        nf.clone() unless already_cached

        if mode == :install and lf and nf.satisfied_with?(lf.locked_version)
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

        nf.requirer = requirer

        trace " #{nf.locked_version}\n"

        nf
      end

      def complete_a_flavor_dependencies(nf, locked_flavor_table, mode, level)
        nf.checkout()
        ff = FlavorFile.load_or_new(nf.cached_repo_path.to_flavorfile_path)
        complete_flavors(ff.flavor_table, locked_flavor_table, mode, level + 1, nf.repo_name)
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

      def trace message
        print message
      end
    end
  end
end

