require 'fileutils'
require 'shellwords'

module Vim
  module Flavor
    class Facade
      def initialize
        @target_repo_names = []
      end

      def install(vimfiles_path)
        install_or_update(:install, vimfiles_path)
      end

      def update(vimfiles_path, target_repo_names)
        @target_repo_names = target_repo_names
        install_or_update(:update, vimfiles_path)
      end

      def test(files_or_dirs, options)
        trace "-------- Preparing dependencies\n"

        flavorfile_path = FlavorFile.path_from(Dir.getwd(), true)
        flavorfile = FlavorFile.load_or_new(flavorfile_path)
        flavorfile.flavor 'kana/vim-vspec', '~> 1.5', :group => :development unless
          flavorfile.flavor_table.has_key?('kana/vim-vspec')
        lockfile_path = LockFile.path_from(Dir.getwd(), true)
        lockfile = LockFile.load_or_new(lockfile_path)
        flavors_path = Dir.getwd().to_stash_path.to_flavors_path

        refresh_flavors(
          options[:update_dependencies] ? :update : :install,
          flavorfile,
          lockfile,
          [:runtime, :development],
          flavors_path
        )

        trace "-------- Testing a Vim plugin\n"

        runner = "#{flavors_path}/#{'kana/vim-vspec'.zap}/bin/prove-vspec"
        plugin_paths = lockfile.flavors.map {|f|
          "#{flavors_path}/#{f.repo_name.zap}"
        }
        runtime_paths = ([Dir.getwd()] + plugin_paths).flat_map {|p| ['-d', p]}
        command =
          %Q{ '#{runner}' \
              #{runtime_paths.flat_map {|p| ['-d', p]}.shelljoin} \
              #{files_or_dirs.shelljoin} }
        succeeded = system('bash', '-c', command)
        exit(1) unless succeeded
      end

      def install_or_update(mode, vimfiles_path)
        flavorfile_path = FlavorFile.path_from(Dir.getwd(), true)
        flavorfile = FlavorFile.load_or_new(flavorfile_path)
        lockfile_path = LockFile.path_from(Dir.getwd(), true)
        lockfile = LockFile.load_or_new(lockfile_path)
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
            mode,
            groups
          )
        )
        lockfile.save()

        deploy_flavors(
          lockfile.flavors,
          File.absolute_path(flavors_path)
        )

        trace "Completed.\n"
      end

      def complete(current_flavor_table, locked_flavor_table, mode, groups)
        nfs = complete_flavors(current_flavor_table, locked_flavor_table, mode, groups, 1, 'you')

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

      def complete_flavors(current_flavor_table, locked_flavor_table, mode, groups, level, requirer)
        current_flavor_table.values.map(&:dup).sort_by(&:repo_name).
        select {|nf| groups.include?(nf.group)}.
        on_failure {trace " failed\n"}.
        flat_map {|nf|
          complete_a_flavor(nf, locked_flavor_table, mode, groups, level, requirer)
        }
      end

      def complete_a_flavor(nf, locked_flavor_table, mode, groups, level, requirer)
        lf = locked_flavor_table[nf.repo_name]
        [complete_a_flavor_itself(nf, lf, mode, level, requirer)] +
          complete_a_flavor_dependencies(nf, locked_flavor_table, mode, groups, level)
      end

      def effective_mode(mode, repo_name)
        return :install if
          mode == :update and
          not @target_repo_names.empty? and
          not @target_repo_names.member?(repo_name)
        mode
      end

      def complete_a_flavor_itself(nf, lf, mode, level, requirer)
        trace "#{'  ' * level}Use #{nf.repo_name} ..."

        already_cached = nf.cached?
        nf.clone() unless already_cached

        e_mode = effective_mode(mode, nf.repo_name)
        if e_mode == :install and lf and nf.satisfied_with?(lf.locked_version)
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

      def complete_a_flavor_dependencies(nf, locked_flavor_table, mode, groups, level)
        nf.checkout()
        flavorfile_path = FlavorFile.path_from(nf.cached_repo_path, false)
        ff = FlavorFile.load_or_new(flavorfile_path)
        complete_flavors(ff.flavor_table, locked_flavor_table, mode, groups, level + 1, nf.repo_name)
      end

      def deploy_flavors(flavors, flavors_path)
        trace "Deploying plugins...\n"

        a_flavors_path = File.absolute_path(flavors_path)
        lockfile_path = LockFile.path_from(a_flavors_path, false)
        deployment_memo = LockFile.load_or_new(lockfile_path)

        # To uninstall flavors which were deployed by vim-flavor 1.0.2 or
        # older, the whole deployed flavors have to be removed.  Because
        # deployment_memo is recorded since 1.0.3.
        FileUtils.rm_rf(
          [a_flavors_path],
          :secure => true
        ) if deployment_memo.flavors.empty?

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

      def trace message
        print message
      end
    end
  end
end

