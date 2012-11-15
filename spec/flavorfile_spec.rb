require 'spec_helper'

module Vim
  module Flavor
    describe FlavorFile do
      describe '#flavor' do
        it 'registers a flavor' do
          ff = FlavorFile.new()
          ff.flavor 'kana/vim-altr', '>= 1.2.3'
          f = ff.flavor_table['kana/vim-altr']
          f.repo_name.should == 'kana/vim-altr'
          f.version_constraint.should == VersionConstraint.new('>= 1.2.3')
        end

        it 'completes version constraint if it is not given' do
          ff = FlavorFile.new()
          ff.flavor 'kana/vim-altr'
          f = ff.flavor_table['kana/vim-altr']
          f.repo_name.should == 'kana/vim-altr'
          f.version_constraint.should == VersionConstraint.new('>= 0')
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

