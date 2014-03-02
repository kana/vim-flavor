require 'spec_helper'

module Vim
  module Flavor
    describe StringExtension do
      describe '#zap' do
        it 'replace unsafe characters with "_"' do
          expect('fakeclip'.zap).to be == 'fakeclip'
          expect('kana/vim-altr'.zap).to be == 'kana_vim-altr'
          expect('git://example.com/foo.git'.zap).to be ==
            'git___example.com_foo.git'
        end
      end
    end
  end
end
