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

          xs.should == [
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

          xs.should == [
            "each 1",
            "after_each 1",
            "each 2",
            "after_each 2",
            "each 3",
            "after_each 3",
          ]
        end
      end
    end
  end
end
