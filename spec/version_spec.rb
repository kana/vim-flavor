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
          Version.correct?('1').should be_true
          Version.correct?('1.2').should be_true
          Version.correct?('1.2.3').should be_true
        end

        it 'accept "vX.Y.Z" style tags' do
          Version.correct?('v1').should be_true
          Version.correct?('v1.2').should be_true
          Version.correct?('v1.2.3').should be_true
        end
      end

      describe '#<=>' do
        it 'can comapre "X.Y.Z" tags' do
          Version.create('1.2.3').should be <= Version.create('1.3')
          Version.create('1.2.3').should be == Version.create('1.2.3')
          Version.create('1.2.3').should be >= Version.create('1.1')
        end

        it 'can comapre "vX.Y.Z" tags' do
          Version.create('v1.2.3').should be <= Version.create('v1.3')
          Version.create('v1.2.3').should be == Version.create('v1.2.3')
          Version.create('v1.2.3').should be >= Version.create('v1.1')
        end

        it 'can comapre "X.Y.Z" tag with "vX.Y.Z" tag' do
          Version.create('1.2.3').should be <= Version.create('v1.3')
          Version.create('1.2.3').should be == Version.create('v1.2.3')
          Version.create('1.2.3').should be >= Version.create('v1.1')
        end
      end

      describe '#to_s' do
        it 'is converted into the original string' do
          Version.create('1.2.3').to_s.should == '1.2.3'
          Version.create('v1.2.3').to_s.should == 'v1.2.3'
        end
      end
    end
  end
end
