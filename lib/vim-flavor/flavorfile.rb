module Vim
  module Flavor
    class FlavorFile
      # repo_name -> flavor
      def flavor_table
        @flavor_table ||= {}
      end

      def default_groups
        @default_groups ||= [:runtime]
      end

      def default_group
        default_groups.last
      end

      def self.load_or_new(flavorfile_path)
        ff = new()
        ff.load(flavorfile_path) if File.exists?(flavorfile_path)
        ff
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

      def flavor(repo_name, version_constraint=nil, group: nil, branch: nil)
        if version_constraint and branch
          throw <<-"END"
Found an invalid declaration on #{repo_name}.
A version constraint '#{version_constraint}' and
a branch '#{branch}' are specified at the same time.
But a branch cannot be used with a version constraint.
          END
        end

        f = Flavor.new()
        f.repo_name = repo_name
        f.version_constraint = VersionConstraint.new(
          branch && "branch: #{branch}" ||
          version_constraint || '>= 0'
        )
        f.group = group || default_group
        flavor_table[f.repo_name] = f
      end

      def group(group, &block)
        default_groups.push(group)
        instance_eval &block
      ensure
        default_groups.pop()
      end
    end
  end
end
