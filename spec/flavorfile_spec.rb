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
    end
  end
end

