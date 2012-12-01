module Vim
  module Flavor
    class FlavorFile
      # repo_name -> flavor
      def flavor_table
        @flavor_table ||= {}
      end

      def default_groups
        @default_groups ||= [:default]
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

      # :call-seq:
      #   flavor repo_name, version_constraint='>= 0', options={} -> a_flavor
      def flavor(repo_name, *args)
        a = args.shift()
        if a.kind_of?(String)
          version_constraint = a
          a = args.shift()
        else
          version_constraint = '>= 0'
        end
        options = a.kind_of?(Hash) ? a : {}

        f = Flavor.new()
        f.repo_name = repo_name
        f.version_constraint = VersionConstraint.new(version_constraint)
        f.group = options[:group] || default_group
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
