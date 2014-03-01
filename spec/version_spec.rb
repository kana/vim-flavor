require 'spec_helper'

module Vim
  module Flavor
    describe Version do
      v = described_class

      describe '::create' do
        it 'makes a PlainVersion' do
          expect(v.create('1.2.3')).to be_a(PlainVersion)
          expect(v.create('v1.2.3')).to be_a(PlainVersion)
        end
      end

      describe '::correct?' do
        it 'is an alias of PlainVersion::correct?' do
          expect(v.correct?('1')).to be_true
          expect(v.correct?('1.2')).to be_true
          expect(v.correct?('1.2.3')).to be_true
          expect(v.correct?('v1')).to be_true
          expect(v.correct?('v1.2')).to be_true
          expect(v.correct?('v1.2.3')).to be_true
          expect(v.correct?('vim7.4')).to be_false
        end
      end
    end
  end
end
