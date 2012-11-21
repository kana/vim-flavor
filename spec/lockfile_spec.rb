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

      describe '#load' do
        it 'loads locked information from a lockfile' do
          File.open(@tmp_path.to_lockfile_path, 'w') do |io|
            io.write(<<-'END')
              foo (1.2.3)
              bar (2.3.4)
              baz (3.4.5)
            END
          end

          l = LockFile.new(@tmp_path.to_lockfile_path)
          l.flavor_table.should be_empty

          l.load()
          l.flavor_table['foo'].repo_name.should == 'foo'
          l.flavor_table['foo'].locked_version.should == '1.2.3'
          l.flavor_table['bar'].repo_name.should == 'bar'
          l.flavor_table['bar'].locked_version.should == '2.3.4'
          l.flavor_table['baz'].repo_name.should == 'baz'
          l.flavor_table['baz'].locked_version.should == '3.4.5'
        end
      end

      describe '::load_or_new' do
        it 'creates a new instance then loads a lockfile' do
          File.open(@tmp_path.to_lockfile_path, 'w') do |io|
            io.write(<<-'END')
              foo (1.2.3)
            END
          end

          l = LockFile.load_or_new(@tmp_path.to_lockfile_path)
          l.flavor_table['foo'].repo_name.should == 'foo'
          l.flavor_table['foo'].locked_version.should == '1.2.3'
        end

        it 'only creates a new instance if a given path does not exist' do
          l = LockFile.load_or_new(@tmp_path.to_lockfile_path)
          l.flavor_table.should be_empty
        end
      end
    end
  end
end
