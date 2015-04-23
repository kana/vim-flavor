module Vim
  module Flavor
    VERSION = '2.2.1'

    class Version
      def self.create(arg)
        if String === arg
          PlainVersion.create(arg)
        else
          BranchVersion.new(arg[:branch], arg[:revision])
        end
      end

      def self.correct?(*args)
        PlainVersion.correct?(*args)
      end
    end
  end
end
