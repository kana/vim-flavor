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
        f.locked_version = v(locked_version)
        f
      end

      def v(s)
        Version.create(s)
      end

      describe '#flavors' do
        it 'is sorted by repo_name' do
          l = LockFile.new(@tmp_path.to_lockfile_path)
          foo = flavor('foo', '1.2.3')
          bar = flavor('bar', '2.3.4')
          baz = flavor('baz', '3.4.5')
          [foo, bar, baz].each do |f|
            l.flavor_table[f.repo_name] = f
          end

          expect(l.flavors).to be == [bar, baz, foo]
        end
      end

      describe '::serialize_lock_status' do
        it 'converts a flavor into an array of lines' do
          expect(
            LockFile.serialize_lock_status(flavor('foo', '1.2.3'))
          ).to be == ['foo (1.2.3)']
        end

        it 'supports a flavor locked to a branch' do
          expect(
            LockFile.serialize_lock_status(
              flavor('foo', branch: 'master', revision: '1' * 40)
            )
          ).to be == ["foo (#{'1' * 40} at master)"]
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
          expect(l.flavor_table).to be_empty

          l.load()
          expect(l.flavor_table['foo'].repo_name).to be == 'foo'
          expect(l.flavor_table['foo'].locked_version).to be == v('1.2.3')
          expect(l.flavor_table['bar'].repo_name).to be == 'bar'
          expect(l.flavor_table['bar'].locked_version).to be == v('2.3.4')
          expect(l.flavor_table['baz'].repo_name).to be == 'baz'
          expect(l.flavor_table['baz'].locked_version).to be == v('3.4.5')
        end

        it 'recognizes flavors with BranchVersion' do
          File.open(@tmp_path.to_lockfile_path, 'w') do |io|
            io.write(<<-"END")
              foo (#{'1' * 40} at master)
              bar (#{'2' * 40} at experimental)
              baz (#{'3' * 40} at stable)
            END
          end

          l = LockFile.new(@tmp_path.to_lockfile_path)
          expect(l.flavor_table).to be_empty

          l.load()
          expect(l.flavor_table['foo'].repo_name).to be == 'foo'
          expect(l.flavor_table['foo'].locked_version).to be ==
            v(branch: 'master', revision: '1' * 40)
          expect(l.flavor_table['bar'].repo_name).to be == 'bar'
          expect(l.flavor_table['bar'].locked_version).to be ==
            v(branch: 'experimental', revision: '2' * 40)
          expect(l.flavor_table['baz'].repo_name).to be == 'baz'
          expect(l.flavor_table['baz'].locked_version).to be ==
            v(branch: 'stable', revision: '3' * 40)
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
          expect(l.flavor_table['foo'].repo_name).to be == 'foo'
          expect(l.flavor_table['foo'].locked_version).to be == v('1.2.3')
        end

        it 'only creates a new instance if a given path does not exist' do
          l = LockFile.load_or_new(@tmp_path.to_lockfile_path)
          expect(l.flavor_table).to be_empty
        end
      end
    end
  end
end
