require 'spec_helper'

module Vim
  module Flavor
    describe VersionConstraint do
      def v(s)
        Version.create(s)
      end

      describe '.parse' do
        def p(*args)
          described_class.parse(*args)
        end

        it 'accepts ">= $version"' do
          expect(p('>= 1.2.3')).to be == [v('1.2.3'), '>=']
        end

        it 'accepts "~> $version"' do
          expect(p('~> 1.2.3')).to be == [v('1.2.3'), '~>']
        end

        it 'accepts "branch: $branch"' do
          expect(p('branch: master')).to be == [v(branch: 'master'), 'branch:']
        end

        it 'ignores extra spaces' do
          expect(p('  ~>  1.2.3  ')).to be == p('~> 1.2.3')
        end

        it 'fails with an unknown qualifier' do
          expect {
            p('!? 1.2.3')
          }.to raise_error('Invalid version constraint: "!? 1.2.3"')
        end

        it 'fails with an invalid format' do
          expect {
            p('1.2.3')
          }.to raise_error('Invalid version constraint: "1.2.3"')

          expect {
            p('>= 2.0 beta')
          }.to raise_error('Invalid version constraint: ">= 2.0 beta"')
        end
      end

      describe '#compatible?' do
        context 'with ">= 1.2.3"' do
          subject {VersionConstraint.new('>= 1.2.3')}

          it {is_expected.to be_compatible v('1.2.3')}

          it {is_expected.to be_compatible v('1.2.4')}
          it {is_expected.to be_compatible v('1.3.3')}
          it {is_expected.to be_compatible v('2.2.3')}

          it {is_expected.to be_compatible v('1.3')}

          it {is_expected.not_to be_compatible v('1.2.2')}
          it {is_expected.not_to be_compatible v('1.1.3')}
          it {is_expected.not_to be_compatible v('0.2.3')}

          it {is_expected.not_to be_compatible v('1.2')}
        end

        context 'with "~> 1.2.3"' do
          subject {VersionConstraint.new('~> 1.2.3')}

          it {is_expected.to be_compatible v('1.2.3')}

          it {is_expected.to be_compatible v('1.2.4')}
          it {is_expected.not_to be_compatible v('1.3.3')}
          it {is_expected.not_to be_compatible v('2.2.3')}

          it {is_expected.not_to be_compatible v('1.3')}

          it {is_expected.not_to be_compatible v('1.2.2')}
          it {is_expected.not_to be_compatible v('1.1.3')}
          it {is_expected.not_to be_compatible v('0.2.3')}

          it {is_expected.not_to be_compatible v('1.2')}
        end

        context 'with "branch: master"' do
          subject {VersionConstraint.new('branch: master')}

          it {is_expected.to be_compatible v(branch: 'master')}
          it {is_expected.to be_compatible v(branch: 'master', revision: '1' * 40)}
          it {is_expected.to be_compatible v(branch: 'master', revision: '2' * 40)}

          it {is_expected.not_to be_compatible v(branch: 'experimental')}
        end
      end

      describe '#find_the_best_version' do
        it 'returns the best version from given versions' do
          versions = ['1.2.2', '1.2.3', '1.2.4', '1.3.3', '2.0'].map {|s| v(s)}
          expect(
            VersionConstraint.new('>= 1.2.3').
            find_the_best_version(versions)
          ).to be == v('2.0')
          expect(
            VersionConstraint.new('~> 1.2.3').
            find_the_best_version(versions)
          ).to be == v('1.2.4')
        end

        it 'fails if no version is given' do
          expect {
            VersionConstraint.new('>= 1.2.3').
              find_the_best_version([]).tap {|v| p v}
          }.to raise_error(RuntimeError, 'There is no valid version')
        end
      end
    end
  end
end
