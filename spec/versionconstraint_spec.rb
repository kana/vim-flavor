require 'spec_helper'

module Vim
  module Flavor
    describe VersionConstraint do
      describe '#compatible?' do
        describe '>=' do
          subject {VersionConstraint.new('>= 1.2.3')}

          it {should be_compatible '1.2.3'}

          it {should be_compatible '1.2.4'}
          it {should be_compatible '1.3.3'}
          it {should be_compatible '2.2.3'}

          it {should be_compatible '1.3'}

          it {should_not be_compatible '1.2.2'}
          it {should_not be_compatible '1.1.3'}
          it {should_not be_compatible '0.2.3'}

          it {should_not be_compatible '1.2'}
        end

        describe '~>' do
          subject {VersionConstraint.new('~> 1.2.3')}

          it {should be_compatible '1.2.3'}

          it {should be_compatible '1.2.4'}
          it {should_not be_compatible '1.3.3'}
          it {should_not be_compatible '2.2.3'}

          it {should_not be_compatible '1.3'}

          it {should_not be_compatible '1.2.2'}
          it {should_not be_compatible '1.1.3'}
          it {should_not be_compatible '0.2.3'}

          it {should_not be_compatible '1.2'}
        end
      end
    end
  end
end
