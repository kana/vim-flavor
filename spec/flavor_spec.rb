require 'spec_helper'

module Vim
  module Flavor
    describe Flavor do
      describe '#satisfied_with?' do
        subject {
          f = Flavor.new()
          f.repo_name = 'foo'
          f.version_constraint = VersionConstraint.new('>= 1.2.3')
          f
        }

        def locked_flavor(repo_name, locked_version)
          f = Flavor.new()
          f.repo_name = repo_name
          f.locked_version = locked_version
          f
        end

        it {should be_satisfied_with locked_flavor('foo', '1.2.3')}

        it {should be_satisfied_with locked_flavor('foo', '1.2.4')}
        it {should be_satisfied_with locked_flavor('foo', '1.3.3')}
        it {should be_satisfied_with locked_flavor('foo', '2.2.3')}

        it {should_not be_satisfied_with locked_flavor('foo', '0.2.3')}
        it {should_not be_satisfied_with locked_flavor('foo', '1.1.3')}
        it {should_not be_satisfied_with locked_flavor('foo', '1.2.2')}

        it {should_not be_satisfied_with locked_flavor('bar', '1.2.3')}
      end
    end
  end
end

