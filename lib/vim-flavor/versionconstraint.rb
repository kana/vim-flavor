module Vim
  module Flavor
    class VersionConstraint
      attr_reader :base_version

      # Specifies how to choose a suitable version according to base_version.
      attr_reader :qualifier

      def initialize(s)
        @base_version, @qualifier = self.class.parse(s)
      end

      def to_s()
        "#{qualifier} #{base_version}"
      end

      def ==(other)
        self.base_version == other.base_version &&
          self.qualifier == other.qualifier
      end

      def self.parse(s)
        m = /^\s*(>=|~>)\s+(\S+)$/.match(s)
        if m
          [Gem::Version.create(m[2]), m[1]]
        else
          raise "Invalid version constraint: #{s.inspect}"
        end
      end
    end
  end
end
