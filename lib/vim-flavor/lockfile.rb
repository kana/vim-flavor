module Vim
  module Flavor
    class LockFile
      def self.load_or_new(lockfile_path)
        l = new(lockfile_path)
        l.load() if File.exists?(lockfile_path)
        l
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

      def flavors=(fs)
        flavor_table.replace(Hash[fs.map {|f| [f.repo_name, f]}])
      end

      def load()
        s = File.open(@path, 'r') {|io| io.read()}
        @flavor_table =
          Hash[LockFileParser.parse(s).map {|f| [f.repo_name, f]}]
      end

      def update(completed_flavor_table)
        @flavor_table = completed_flavor_table
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
