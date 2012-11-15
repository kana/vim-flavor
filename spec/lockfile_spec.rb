require 'spec_helper'
require 'tmpdir'

module Vim
  module Flavor
    describe LockFile do
      around :each do |example|
        Dir.mktmpdir do |tmp_path|
          @tmp_path = tmp_path
          example.run
        end
      end

      def flavor(repo_name, locked_version)
        f = Flavor.new()
        f.repo_name = repo_name
        f.locked_version = locked_version
        f
      end

      it 'has flavors sorted by repo_name' do
        l = LockFile.new(@tmp_path.to_lockfile_path)
        foo = flavor('foo', '1.2.3')
        bar = flavor('bar', '2.3.4')
        baz = flavor('baz', '3.4.5')
        [foo, bar, baz].each do |f|
          l.flavor_table[f.repo_name] = f
        end

        l.flavors.should == [bar, baz, foo]
      end

      describe '::serialize_lock_status' do
        it 'converts a flavor into an array of lines' do
          LockFile.serialize_lock_status(flavor('foo', '1.2.3')).should ==
            ['foo (1.2.3)']
        end
      end
    end
  end
end
