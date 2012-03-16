require 'bundler/setup'
require 'fileutils'
require 'vim-flavor'

describe Vim::Flavor::Facade do
  describe '#initialize' do
    it 'should have proper values by default' do
      facade = described_class.new()
      facade.flavorfile.should == nil
      facade.flavorfile_path.should == "#{Dir.getwd()}/VimFlavor"
      facade.lockfile.should == nil
      facade.lockfile_path.should == "#{Dir.getwd()}/VimFlavor.lock"
    end
  end
end
