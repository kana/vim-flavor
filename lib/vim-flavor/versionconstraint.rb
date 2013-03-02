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
          [Version.create(m[2]), m[1]]
        else
          raise "Invalid version constraint: #{s.inspect}"
        end
      end

      def compatible?(other_version_or_s)
        v = Version.create(other_version_or_s)
        if qualifier == '~>'
          self.base_version.bump() > v and v >= self.base_version
        elsif qualifier == '>='
          v >= self.base_version
        else
          raise NotImplementedError
        end
      end

      def find_the_best_version(versions)
        versions.
          select {|v| compatible?(v)}.
          max() or raise 'There is no valid version'
      end
    end
  end
end
