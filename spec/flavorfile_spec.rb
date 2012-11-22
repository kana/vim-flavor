require 'spec_helper'

module Vim
  module Flavor
    describe FlavorFile do
      describe '#flavor' do
        let(:ff) {FlavorFile.new()}

        context 'basics' do
          it 'registers a flavor' do
            ff.flavor 'kana/vim-altr', '>= 1.2.3'
            f = ff.flavor_table['kana/vim-altr']
            f.repo_name.should == 'kana/vim-altr'
            f.version_constraint.should == VersionConstraint.new('>= 1.2.3')
          end

          it 'completes version constraint if it is not given' do
            ff.flavor 'kana/vim-altr'
            f = ff.flavor_table['kana/vim-altr']
            f.repo_name.should == 'kana/vim-altr'
            f.version_constraint.should == VersionConstraint.new('>= 0')
          end
        end

        context 'group option' do
          it 'supports a group option with a version constraint' do
            ff.flavor 'kana/vim-vspec', '~> 1.0', :group => :development
            f = ff.flavor_table['kana/vim-vspec']
            f.version_constraint.should == VersionConstraint.new('~> 1.0')
            f.group.should == :development
          end

          it 'supports a group option without version constraint' do
            ff.flavor 'kana/vim-vspec', :group => :development
            f = ff.flavor_table['kana/vim-vspec']
            f.version_constraint.should == VersionConstraint.new('>= 0')
            f.group.should == :development
          end

          it 'uses :default as the default group' do
            ff.flavor 'kana/vim-vspec'
            f = ff.flavor_table['kana/vim-vspec']
            f.group.should == :default
          end
        end

        context 'group block' do
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

            ff.flavor_table['a'].group.should == :default
            ff.flavor_table['b'].group.should == :outer
            ff.flavor_table['c'].group.should == :inner
            ff.flavor_table['d'].group.should == :outer
            ff.flavor_table['e'].group.should == :default
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

            ff.flavor_table['a'].group.should == :default
            ff.flavor_table['b'].group.should == :outer
            ff.flavor_table['c'].should be_nil
            ff.flavor_table['d'].group.should == :outer
            ff.flavor_table['e'].group.should == :default
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
          f.repo_name.should == 'kana/vim-altr'
          f.version_constraint.should == VersionConstraint.new('~> 1.2')
        end
      end
    end
  end
end

