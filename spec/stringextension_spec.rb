require 'spec_helper'

module Vim
  module Flavor
    describe StringExtension do
      describe '#zap' do
        it 'replace unsafe characters with "_"' do
          'fakeclip'.zap.should == 'fakeclip'
          'kana/vim-altr'.zap.should == 'kana_vim-altr'
          'git://example.com/foo.git'.zap.should == 'git___example.com_foo.git'
        end
      end
    end
  end
end
