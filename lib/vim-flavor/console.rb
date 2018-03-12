module Vim
  module Flavor
    module Console
      def self.warn message
        puts "Warning: #{message}"
      end
    end
  end
end
