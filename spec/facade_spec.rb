require 'fileutils'
require 'spec_helper'
require 'tmpdir'

module Vim
  module Flavor
    describe Facade do
      describe '#create_vim_script_for_bootstrap' do
        around :each do |example|
          Dir.mktmpdir do |tmp_path|
            @tmp_path = tmp_path
            example.run
          end
        end

        it 'creates a bootstrap script to configure runtimepath for flavors' do
          flavors_path = @tmp_path.to_vimfiles_path.to_flavors_path
          Facade.new().create_vim_script_for_bootstrap(flavors_path)

          expect(File).to exist(flavors_path.to_bootstrap_path)

          _rtp = %x{
            for plugin_name in 'foo' 'bar' 'baz'
            do
              mkdir -p "#{flavors_path}/$plugin_name"
            done
            HOME='#{@tmp_path}' vim -u NONE -i NONE -n -N -e -s -c '
              set verbose=1
              let vimfiles_path = split(&runtimepath, ",")[0]
              runtime flavors/bootstrap.vim
              for path in split(&runtimepath, ",")
                if stridx(path, vimfiles_path) == 0
                  echo substitute(path, vimfiles_path, "!", "")
                endif
              endfor
              qall!
            ' 2>&1
          }
          rtps =
            _rtp.
            split(/[\r\n]/).
            select {|p| p != ''}
          expect(rtps).to be == [
            '!',
            '!/flavors/bar',
            '!/flavors/baz',
            '!/flavors/foo',
            '!/flavors/foo/after',
            '!/flavors/baz/after',
            '!/flavors/bar/after',
            '!/after',
          ]
        end
      end
    end
  end
end
