module Vim
  module Flavor
    module StringExtension
      def to_flavors_path()
        "#{self}/flavors"
      end
    end
  end
end
