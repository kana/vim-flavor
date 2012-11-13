module Vim
  module Flavor
    class FlavorFile
      def complete(locked_flavor_table)
        completed_flavor_table = {}

        flavor_table.each do |repo_name, cf|
          nf = cf.dup()
          lf = locked_flavor_table[repo_name]

          already_cached = nf.cached?
          nf.clone() unless already_cached

          if lf and nf.satisfies?(lf)
            nf.use_specific_version(lf.locked_version)
          else
            nf.fetch() if already_cached
            nf.use_appropriate_version()
          end

          completed_flavor_table[repo_name] = nf
        end

        completed_flavor_table
      end
    end
  end
end
