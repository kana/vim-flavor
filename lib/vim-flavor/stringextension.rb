module Vim
  module Flavor
    module StringExtension
      def to_flavors_path()
        "#{self}/flavors"
      end
    end

    class ::String
      include StringExtension
    end
  end
end
