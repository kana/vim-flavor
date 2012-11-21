module Vim
  module Flavor
    EnumerableExtension = ::Enumerable

    module EnumerableExtension
      def before_each(&block)
        vs = each
        Enumerator.new do |y|
          loop do
            v = vs.next
            block.call(v)
            y << v
          end
        end
      end

      def after_each(&block)
        vs = each
        Enumerator.new do |y|
          loop do
            v = vs.next
            y << v
            block.call(v)
          end
        end
      end
    end
  end
end
