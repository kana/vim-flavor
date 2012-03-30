require 'yaml'

module Vim
  module Flavor
    class LockFile
      # TODO: Resolve dependencies recursively.

      attr_reader :flavors, :path

      def initialize(path)
        @flavors = {}  # repo_uri => flavor
        @path = path
      end

      def load()
        h = File.open(@path, 'rb') do |f|
          YAML.load(f.read())
        end

        @flavors = self.class.flavors_from_poro(h[:flavors])
      end

      def save()
        h = {}

        h[:flavors] = self.class.poro_from_flavors(@flavors)

        File.open(@path, 'wb') do |f|
          YAML.dump(h, f)
        end
      end

      def self.poro_from_flavors(flavors)
        Hash[
          flavors.values.map {|f|
            [
              f.repo_uri,
              {
                :groups => f.groups,
                :locked_version => f.locked_version.to_s(),
                :repo_name => f.repo_name,
                :version_contraint => f.version_contraint.to_s(),
              }
            ]
          }
        ]
      end

      def self.flavors_from_poro(poro)
        Hash[
          poro.to_a().map {|repo_uri, h|
            f = Flavor.new()
            f.groups = h[:groups]
            f.locked_version = Gem::Version.create(h[:locked_version])
            f.repo_name = h[:repo_name]
            f.repo_uri = repo_uri
            f.version_contraint = VersionConstraint.new(h[:version_contraint])
            [f.repo_uri, f]
          }
        ]
      end
    end
  end
end
