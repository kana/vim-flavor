module Vim
  module Flavor
    VERSION = '1.1.5'

    class Version
      def self.create(*args)
        PlainVersion.create(*args)
      end

      def self.correct?(*args)
        PlainVersion.correct?(*args)
      end
    end
  end
end
