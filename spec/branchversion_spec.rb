require 'spec_helper'

module Vim
  module Flavor
    describe BranchVersion do
      def v(*args)
        described_class.new(*args)
      end

      let(:v1) {v('master', '1' * 40)}
      let(:v1d) {v('master', '1' * 40)}
      let(:v2) {v('master', '2' * 40)}

      it 'is equatable' do
        expect(v1).to be == v1
        expect(v1).to be == v1d
        expect(v1).not_to be == v2
      end

      it 'is not comparable' do
        expect {v1 < v2}.to raise_error
        expect {v1 <= v2}.to raise_error
        expect {v1 > v2}.to raise_error
        expect {v1 >= v2}.to raise_error
        expect(v1 <=> v2).to be_nil
      end

      describe '#to_s' do
        it 'makes a user-friendly representation' do
          expect(v1.to_s).to be == "#{'1' * 40} at master"
        end
      end

      describe '#to_revision' do
        it 'returns a revision corresponding to a branch' do
          expect(v('master', '1' * 40).to_revision).to be == '1' * 40
          expect(v('experimental', '2' * 40).to_revision).to be == '2' * 40
        end

        it 'fails if a revision is not known' do
          expect {
            v('master', nil).to_revision
          }.to raise_error(
            /Internal error: A revision of a branch master is not known/
          )
        end
      end
    end
  end
end
