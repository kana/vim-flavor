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

      def self.serialize_lock_status(flavor)
        ["#{flavor.repo_name} (#{flavor.locked_version})"]
      end

      def save()
        File.open(@path, 'w') do |io|
          lines = flavors.flat_map {|f| self.class.serialize_lock_status(f)}
          lines.each do |line|
            io.write(line)
            io.write("\n")
          end
        end
      end
    end
  end
end
