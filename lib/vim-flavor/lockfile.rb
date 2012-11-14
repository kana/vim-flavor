module Vim
  module Flavor
    class LockFile
      def self.load_or_new(lockfile_path)
        # TODO: Implement.
        new()
      end

      def flavor_table
        @flavor_table ||= {}
      end

      def update(completed_flavor_table)
        # TODO: Implement.
      end
    end
  end
end
