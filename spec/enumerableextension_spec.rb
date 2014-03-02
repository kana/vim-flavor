require 'spec_helper'

module Vim
  module Flavor
    describe EnumerableExtension do
      describe '#before_each' do
        it 'runs a given block before enumerating each element' do
          xs = []
          [1, 2, 3].
          before_each {|n| xs << "before_each #{n}"}.
          each do |n|
            xs << "each #{n}"
          end

          expect(xs).to be == [
            "before_each 1",
            "each 1",
            "before_each 2",
            "each 2",
            "before_each 3",
            "each 3",
          ]
        end
      end

      describe '#after_each' do
        it 'runs a given block after enumerating each element' do
          xs = []
          [1, 2, 3].
          after_each {|n| xs << "after_each #{n}"}.
          each do |n|
            xs << "each #{n}"
          end

          expect(xs).to be == [
            "each 1",
            "after_each 1",
            "each 2",
            "after_each 2",
            "each 3",
            "after_each 3",
          ]
        end
      end

      describe '#on_failure' do
        it 'runs a given block if a core block raises an exception' do
          xs = []

          expect {
            [1, 2, 3].
            on_failure {|n| xs << "on_failure #{n}"}.
            each do |n|
              xs << "each enter #{n}"
              raise RuntimeError, "bang! #{n}" if 2 < n
              xs << "each leave #{n}"
            end
          }.to raise_error(RuntimeError, 'bang! 3')

          expect(xs).to be == [
            "each enter 1",
            "each leave 1",
            "each enter 2",
            "each leave 2",
            "each enter 3",
            "on_failure 3",
          ]
        end

        it 'runs a given block with null if a yielder raises an exception' do
          xs = []
          e = Object.new()
          def e.each
            yield 1
            yield 2
            raise RuntimeError, 'bang!'
            yield 3
          end

          expect {
            e.to_enum.
            on_failure {|n| xs << "on_failure #{n.class}"}.
            each do |n|
              xs << "each enter #{n}"
              xs << "each leave #{n}"
            end
          }.to raise_error(RuntimeError, 'bang!')

          expect(xs).to be == [
            "each enter 1",
            "each leave 1",
            "each enter 2",
            "each leave 2",
            "on_failure #{nil.class}",
          ]
        end
      end
    end
  end
end
