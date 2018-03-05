require 'spec_helper'

module Vim
  module Flavor
    describe StringExtension do
      describe '#to_flavorfile_path' do
        it 'extends a given path to a flavorfile' do
          expect('cwd'.to_flavorfile_path).to be == 'cwd/VimFlavor'
        end
      end

      describe '#to_flavors_path' do
        it 'extends a given path to a flavors path' do
          expect('home/.vim'.to_flavors_path).to be == 'home/.vim/pack/flavors/start'
        end
      end

      describe '#to_lockfile_path' do
        it 'extends a given path to a lockfile' do
          expect('cwd'.to_lockfile_path).to be == 'cwd/VimFlavor.lock'
        end
      end

      describe '#to_stash_path' do
        it 'extends a given path to a stash path' do
          expect('home'.to_stash_path).to be == 'home/.vim-flavor'
          expect('cwd'.to_stash_path).to be == 'cwd/.vim-flavor'
        end
      end

      describe '#to_vimfiles_path' do
        it 'extends a given path to a vimfiles path' do
          expect('home'.to_vimfiles_path).to be == 'home/.vim'
        end
      end

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
