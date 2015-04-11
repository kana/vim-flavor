require 'spec_helper'

module Vim
  module Flavor
    describe PlainVersion do
      v = described_class

      describe '::create' do
        it 'accept "X.Y.Z" style tags' do
          expect {
            v.create('1')
            v.create('1.2')
            v.create('1.2.3')
          }.not_to raise_error
        end

        it 'accept "vX.Y.Z" style tags' do
          expect {
            v.create('v1')
            v.create('v1.2')
            v.create('v1.2.3')
          }.not_to raise_error
        end
      end

      describe '::correct?' do
        it 'accept "X.Y.Z" style tags' do
          expect(v.correct?('1')).to be_truthy
          expect(v.correct?('1.2')).to be_truthy
          expect(v.correct?('1.2.3')).to be_truthy
        end

        it 'accept "vX.Y.Z" style tags' do
          expect(v.correct?('v1')).to be_truthy
          expect(v.correct?('v1.2')).to be_truthy
          expect(v.correct?('v1.2.3')).to be_truthy
        end
      end

      describe '#<=>' do
        it 'can comapre "X.Y.Z" tags' do
          expect(v.create('1.2.3')).to be <= v.create('1.3')
          expect(v.create('1.2.3')).to be == v.create('1.2.3')
          expect(v.create('1.2.3')).to be >= v.create('1.1')
        end

        it 'can comapre "vX.Y.Z" tags' do
          expect(v.create('v1.2.3')).to be <= v.create('v1.3')
          expect(v.create('v1.2.3')).to be == v.create('v1.2.3')
          expect(v.create('v1.2.3')).to be >= v.create('v1.1')
        end

        it 'can comapre "X.Y.Z" tag with "vX.Y.Z" tag' do
          expect(v.create('1.2.3')).to be <= v.create('v1.3')
          expect(v.create('1.2.3')).to be == v.create('v1.2.3')
          expect(v.create('1.2.3')).to be >= v.create('v1.1')
        end
      end

      describe '#to_s' do
        it 'is converted into the original string' do
          expect(v.create('1.2.3').to_s).to be == '1.2.3'
          expect(v.create('v1.2.3').to_s).to be == 'v1.2.3'
        end
      end

      describe '#to_revision' do
        it 'returns the revision corresponding to a version' do
          expect(v.create('1.2.3').to_revision).to be == '1.2.3'
          expect(v.create('v1.2.3').to_revision).to be == 'v1.2.3'
        end
      end
    end
  end
end
