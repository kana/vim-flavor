module Vim
  module Flavor
    class LockFile
      def self.load_or_new(lockfile_path)
        # TODO: Implement.
        new(lockfile_path)
      end

      def initialize(path)
        @path = path
      end

      def flavor_table
        @flavor_table ||= {}
      end

      def flavors
        flavor_table.values.sort_by {|f| f.repo_name}
      end

      def update(completed_flavor_table)
        # TODO: Implement.
      end

      def save()
        # TODO: Implement.
      end
    end
  end
end
