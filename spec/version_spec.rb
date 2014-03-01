require 'spec_helper'

module Vim
  module Flavor
    describe Version do
      describe '::create' do
        it 'accept "X.Y.Z" style tags' do
          expect {
            Version.create('1')
            Version.create('1.2')
            Version.create('1.2.3')
          }.not_to raise_error
        end

        it 'accept "vX.Y.Z" style tags' do
          expect {
            Version.create('v1')
            Version.create('v1.2')
            Version.create('v1.2.3')
          }.not_to raise_error
        end
      end

      describe '::correct?' do
        it 'accept "X.Y.Z" style tags' do
          expect(Version.correct?('1')).to be_true
          expect(Version.correct?('1.2')).to be_true
          expect(Version.correct?('1.2.3')).to be_true
        end

        it 'accept "vX.Y.Z" style tags' do
          expect(Version.correct?('v1')).to be_true
          expect(Version.correct?('v1.2')).to be_true
          expect(Version.correct?('v1.2.3')).to be_true
        end
      end

      describe '#<=>' do
        it 'can comapre "X.Y.Z" tags' do
          expect(Version.create('1.2.3')).to be <= Version.create('1.3')
          expect(Version.create('1.2.3')).to be == Version.create('1.2.3')
          expect(Version.create('1.2.3')).to be >= Version.create('1.1')
        end

        it 'can comapre "vX.Y.Z" tags' do
          expect(Version.create('v1.2.3')).to be <= Version.create('v1.3')
          expect(Version.create('v1.2.3')).to be == Version.create('v1.2.3')
          expect(Version.create('v1.2.3')).to be >= Version.create('v1.1')
        end

        it 'can comapre "X.Y.Z" tag with "vX.Y.Z" tag' do
          expect(Version.create('1.2.3')).to be <= Version.create('v1.3')
          expect(Version.create('1.2.3')).to be == Version.create('v1.2.3')
          expect(Version.create('1.2.3')).to be >= Version.create('v1.1')
        end
      end

      describe '#to_s' do
        it 'is converted into the original string' do
          expect(Version.create('1.2.3').to_s).to be == '1.2.3'
          expect(Version.create('v1.2.3').to_s).to be == 'v1.2.3'
        end
      end
    end
  end
end
