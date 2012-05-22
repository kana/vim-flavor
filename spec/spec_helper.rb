require 'bundler/setup'
require 'fileutils'
require 'spec_helper'
require 'tmpdir'
require 'vim-flavor'

def create_a_test_repo(path)
  system(<<-"END")
    {
      mkdir -p #{path.inspect}
      cd #{path.inspect}
      git init
      mkdir autoload doc plugin
      touch autoload/foo.vim doc/foo.txt plugin/foo.vim
      git add autoload doc plugin
      git commit -am 'Commit foo'
      for version in '1.0.0' '1.1.1' '1.1.2' '1.2.1' '1.2.2'
      do
        echo "*foo* $version" >doc/foo.txt
        git commit -am 'Update foo'
        git tag -a -m "Version $version" "$version"
      done
      for non_version in 'foo' 'bar' 'baz'
      do
        git tag -a -m "Non-version $non_version" "$non_version"
      done
    } >/dev/null
  END
end

def update_a_test_repo(path)
  system(<<-"END")
    {
      cd #{path.inspect} &&
      for version in '1.0.9' '1.1.9' '1.2.9' '1.3.9'
      do
        echo "*foo* $version" >doc/foo.txt
        git commit -am 'Update foo'
        git tag -a -m "Version $version" "$version"
      done
    } >/dev/null
  END
end

def create_temporary_directory()
  Dir.mktmpdir()
end

def remove_temporary_directory(path)
  FileUtils.remove_entry_secure(path)
end

def with_temporary_directory()
  before :each do
    @tmp_path = create_temporary_directory()

    @original_dot_path = Vim::Flavor.dot_path
    @dot_path = "#{@tmp_path}/.vim-flavor"
    Vim::Flavor.dot_path = @dot_path
  end

  after :each do
    Vim::Flavor.dot_path = @original_dot_path

    remove_temporary_directory(@tmp_path)
  end
end
