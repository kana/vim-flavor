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

      def flavor(repo_name, version_constraint='>= 0')
        f = Flavor.new()
        f.repo_name = repo_name
        f.version_constraint = VersionConstraint.new(version_constraint)
        flavor_table[f.repo_name] = f
      end
    end
  end
end
