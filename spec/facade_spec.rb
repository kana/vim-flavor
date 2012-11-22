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
          vimfiles_path = @tmp_path.to_vimfiles_path
          Facade.new().create_vim_script_for_bootstrap(vimfiles_path)

          File.should exist(vimfiles_path.to_flavors_path.to_bootstrap_path)

          _rtp = %x{
            for plugin_name in 'foo' 'bar' 'baz'
            do
              mkdir -p "#{vimfiles_path.to_flavors_path}/$plugin_name"
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
          rtps.should == [
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

      describe '#make_may_deploy' do
        let(:f) {Facade.new()}
        let(:a) {f = Flavor.new(); f.group = :a; f}
        let(:b) {f = Flavor.new(); f.group = :b; f}

        it 'always returns true if nothing is specified' do
          m = f.make_may_deploy(nil, nil)
          m.call(a).should be_true
          m.call(b).should be_true
        end

        it 'returns true only for name in with_groups' do
          m = f.make_may_deploy([:a], nil)
          m.call(a).should be_true
          m.call(b).should be_false
        end

        it 'returns false only for name in without_groups' do
          m = f.make_may_deploy(nil, [:b])
          m.call(a).should be_true
          m.call(b).should be_false
        end

        it 'fails if with_groups and without_groups are given at once' do
          expect {
            f.make_may_deploy([:a], [:b])
          }.to raise_error
        end
      end
    end
  end
end
