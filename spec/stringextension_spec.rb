require 'bundler/setup'
require 'spec_helper'
require 'vim-flavor'

describe Vim::Flavor::StringExtension do
  describe '#to_flavors_path' do
    it 'should return a flavors path from a vimfiles path' do
      '~/.vim'.to_flavors_path().should == '~/.vim/flavors'
    end
  end
end
