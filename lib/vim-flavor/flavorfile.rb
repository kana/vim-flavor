module Vim
  module Flavor
    class FlavorFile
      attr_reader :flavors

      def initialize()
        @flavors = {}
        @default_groups = [:default]
      end

      def interpret(&block)
        instance_eval(&block)
      end

      def eval_flavorfile(flavorfile_path)
        content = File.open(flavorfile_path, 'rb') do |f|
          f.read()
        end
        interpret do
          instance_eval(content)
        end
      end

      def repo_uri_from_repo_name(repo_name)
        if /^([^\/]+)$/.match(repo_name) then
          m = Regexp.last_match
          "git://github.com/vim-scripts/#{m[1]}.git"
        elsif /^([A-Za-z0-9_-]+)\/(.*)$/.match(repo_name) then
          m = Regexp.last_match
          "git://github.com/#{m[1]}/#{m[2]}.git"
        elsif /^[a-z]+:\/\/.*$/.match(repo_name) then
          repo_name
        else
          raise "repo_name is written in invalid format: #{repo_name.inspect}"
        end
      end

      def flavor(repo_name, *args)
        options = Hash === args.last ? args.pop : {}
        options[:groups] ||= []
        version_contraint = VersionConstraint.new(args.last || '>= 0')

        f = Flavor.new()
        f.repo_name = repo_name
        f.repo_uri = repo_uri_from_repo_name(repo_name)
        f.version_contraint = version_contraint
        f.groups = @default_groups + options[:groups]

        @flavors[f.repo_uri] = f
      end

      def group(*group_names, &block)
        @default_groups.concat(group_names)
        yield
      ensure
        group_names.each do
          @default_groups.pop()
        end
      end
    end
  end
end
