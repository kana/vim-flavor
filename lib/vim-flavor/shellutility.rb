module Vim
  module Flavor
    module ShellUtility
      def sh script
        output = send(:`, script)
        if $? == 0
          output
        else
          raise RuntimeError, output
        end
      end
    end
  end
end
