require 'spec_helper'

module Vim
  module Flavor
    describe Flavor do
      describe '#versions_from_tags' do
        def example tags, versions
          f = Flavor.new()
          f.versions_from_tags(tags).sort.map(&:version).should == versions
        end

        it 'converts tags into versions' do
          example ['1.2', '2.4.6', '3.6'], ['1.2', '2.4.6', '3.6']
        end

        it 'accepts also prelerease tags' do
          example ['1.2a', '2.4.6b', '3.6c'], ['1.2a', '2.4.6b', '3.6c']
        end

        it 'drops non-version tags' do
          example ['1.2', '2.4.6_', 'test', '2.9'], ['1.2', '2.9']
        end
      end

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

