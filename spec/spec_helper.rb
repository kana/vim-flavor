require 'bundler/setup'
require 'fileutils'

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
      echo '*foo*' >doc/foo.txt
      git commit -am 'Update foo'
      git tag -a -m 'Version 1.0.0' 1.0.0
      git tag -a -m 'Version 1.1.1' 1.1.1
      git tag -a -m 'Version 1.1.2' 1.1.2
      git tag -a -m 'Version 1.2.1' 1.2.1
      git tag -a -m 'Version 1.2.2' 1.2.2
    } >/dev/null
  END
end

def update_a_test_repo(path)
  system(<<-"END")
    {
      cd #{path.inspect} &&
      echo '*foo* *bar*' >doc/foo.txt &&
      git commit -am 'Update foo again'
    } >/dev/null
  END
end

def clean_up_stashed_stuffs()
  FileUtils.rm_rf([Vim::Flavor::DOT_PATH], :secure => true)
end
