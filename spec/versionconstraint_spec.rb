require 'spec_helper'

module Vim
  module Flavor
    describe VersionConstraint do
      def v(s)
        Version.create(s)
      end

      describe '#compatible?' do
        describe '>=' do
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

        describe '~>' do
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
