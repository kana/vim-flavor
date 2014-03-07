require 'spec_helper'

module Vim
  module Flavor
    describe FlavorFile do
      def constraint(*args)
        VersionConstraint.new(*args)
      end

      describe '#flavor' do
        let(:ff) {FlavorFile.new()}

        context 'with basic usage' do
          it 'registers a flavor' do
            ff.flavor 'kana/vim-altr', '>= 1.2.3'
            f = ff.flavor_table['kana/vim-altr']
            expect(f.repo_name).to be == 'kana/vim-altr'
            expect(f.version_constraint).to be == constraint('>= 1.2.3')
          end

          it 'completes a version constraint if it is not given' do
            ff.flavor 'kana/vim-altr'
            f = ff.flavor_table['kana/vim-altr']
            expect(f.repo_name).to be == 'kana/vim-altr'
            expect(f.version_constraint).to be == constraint('>= 0')
          end
        end

        context 'with a group option' do
          it 'supports a group option with a version constraint' do
            ff.flavor 'kana/vim-vspec', '~> 1.0', :group => :development
            f = ff.flavor_table['kana/vim-vspec']
            expect(f.version_constraint).to be == constraint('~> 1.0')
            expect(f.group).to be == :development
          end

          it 'supports a group option without version constraint' do
            ff.flavor 'kana/vim-vspec', :group => :development
            f = ff.flavor_table['kana/vim-vspec']
            expect(f.version_constraint).to be == constraint('>= 0')
            expect(f.group).to be == :development
          end

          it 'uses :default as the default group' do
            ff.flavor 'kana/vim-vspec'
            f = ff.flavor_table['kana/vim-vspec']
            expect(f.group).to be == :runtime
          end
        end

        context 'in a group block' do
          it 'changes the default group for flavors in a given block' do
            ff.flavor 'a'
            ff.group :outer do
              flavor 'b'
              group :inner do
                flavor 'c'
              end
              flavor 'd'
            end
            ff.flavor 'e'

            expect(ff.flavor_table['a'].group).to be == :runtime
            expect(ff.flavor_table['b'].group).to be == :outer
            expect(ff.flavor_table['c'].group).to be == :inner
            expect(ff.flavor_table['d'].group).to be == :outer
            expect(ff.flavor_table['e'].group).to be == :runtime
          end

          it 'restores the default group even if an exception is raised' do
            ff.flavor 'a'
            ff.group :outer do
              begin
                flavor 'b'
                group :inner do
                  raise RuntimeError
                  flavor 'c'
                end
              rescue
              end
              flavor 'd'
            end
            ff.flavor 'e'

            expect(ff.flavor_table['a'].group).to be == :runtime
            expect(ff.flavor_table['b'].group).to be == :outer
            expect(ff.flavor_table['c']).to be_nil
            expect(ff.flavor_table['d'].group).to be == :outer
            expect(ff.flavor_table['e'].group).to be == :runtime
          end
        end

        context 'with a branch option' do
          it 'is supported' do
            ff.flavor 'kana/vim-altr', branch: 'master'
            f = ff.flavor_table['kana/vim-altr']
            expect(f.repo_name).to be == 'kana/vim-altr'
            expect(f.version_constraint).to be == constraint('branch: master')
          end

          it 'cannot be used with a version constraint' do
            expect {
              ff.flavor 'kana/vim-altr', '>= 0', branch: 'master'
            }.to raise_error(/branch cannot be used with a version constraint/)
          end
        end
      end

      describe '.load' do
        around(:each) do |example|
          Dir.mktmpdir do |dir|
            @tmp_path = dir
            example.run
          end
        end

        it 'loads a given flavorfile' do
          flavorfile_path = @tmp_path.to_flavorfile_path
          File.open(flavorfile_path, 'w') do |io|
            io.write("flavor 'kana/vim-altr', '~> 1.2'\n")
          end
          ff = FlavorFile.load(flavorfile_path)
          f = ff.flavor_table['kana/vim-altr']
          expect(f.repo_name).to be == 'kana/vim-altr'
          expect(f.version_constraint).to be == constraint('~> 1.2')
        end
      end
    end
  end
end

