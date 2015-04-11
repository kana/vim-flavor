require 'spec_helper'

module Vim
  module Flavor
    describe Version do
      v = described_class

      describe '::create' do
        context 'with a string' do
          it 'makes a PlainVersion' do
            expect(v.create('1.2.3')).to be_a(PlainVersion)
            expect(v.create('v1.2.3')).to be_a(PlainVersion)
          end
        end

        context 'with a branch' do
          it 'makes a BranchVersion' do
            r = v.create(branch: 'master')
            expect(r).to be_a(BranchVersion)
            expect(r.branch).to be == 'master'
            expect(r.revision).to be_nil
          end
        end

        context 'with a branch and a ref' do
          it 'makes a BranchVersion' do
            r = v.create(branch: 'master', revision: '1' * 40)
            expect(r).to be_a(BranchVersion)
            expect(r.branch).to be == 'master'
            expect(r.revision).to be == '1' * 40
          end
        end
      end

      describe '::correct?' do
        it 'is an alias of PlainVersion::correct?' do
          expect(v.correct?('1')).to be_truthy
          expect(v.correct?('1.2')).to be_truthy
          expect(v.correct?('1.2.3')).to be_truthy
          expect(v.correct?('v1')).to be_truthy
          expect(v.correct?('v1.2')).to be_truthy
          expect(v.correct?('v1.2.3')).to be_truthy
          expect(v.correct?('vim7.4')).to be_falsey
        end
      end
    end
  end
end
