module Vim
  module Flavor
    class FlavorFile
      # repo_name -> flavor
      def flavor_table
        @flavor_table ||= {}
      end

      def self.load(flavorfile_path)
        ff = new()
        ff.load(flavorfile_path)
        ff
      end

      def load(flavorfile_path)
        instance_eval(
          File.open(flavorfile_path, 'r').read(),
          flavorfile_path
        )
      end

      def complete(locked_flavor_table)
        completed_flavor_table = {}

        flavor_table.each do |repo_name, cf|
          nf = cf.dup()
          lf = locked_flavor_table[repo_name]

          already_cached = nf.cached?
          nf.clone() unless already_cached

          if lf and nf.satisfied_with?(lf)
            nf.use_specific_version(lf.locked_version)
          else
            nf.fetch() if already_cached
            nf.use_appropriate_version()
          end

          completed_flavor_table[repo_name] = nf
        end

        completed_flavor_table
      end

      def flavor(repo_name, version_constraint='>= 0')
        f = Flavor.new()
        f.repo_name = repo_name
        f.version_constraint = VersionConstraint.new(version_constraint)
        flavor_table[f.repo_name] = f
      end
    end
  end
end
