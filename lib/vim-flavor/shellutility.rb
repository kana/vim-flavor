module Vim
  module Flavor
    module ShellUtility
      def sh script
        output = IO.popen(['bash', '-c', script], 'r', &:read)

        if $? == 0
          output
        else
          raise RuntimeError, output
        end
      end
    end
  end
end
