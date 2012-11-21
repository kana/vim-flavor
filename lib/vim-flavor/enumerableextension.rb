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

      def on_failure(&block)
        vs = each
        Enumerator.new do |y|
          v = nil
          begin
            loop do
              v = vs.next
              y << v
              v = nil
            end
          rescue StopIteration
            raise
          rescue
            block.call(v)
            raise
          end
        end
      end
    end
  end
end
