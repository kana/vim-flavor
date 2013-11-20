Feature: Specifying test scripts
  In order to run test scripts not in the standard `t` directory,
  As a lazy Vim user,
  I want to specify test scripts to be run,
  like `vim-flavor test FILES-OR-DIRECTOREIS`.

  Background:
    Given a repository "kana/vim-vspec" from offline cache

  Scenario: Running test scripts in non-standard location
    Given a flavorfile with:
      """ruby
      # No dependency
      """
    And a file named "plugin/foo.vim" with:
      """vim
      let g:foo = 3
      """
    And a file named "spec/basics.vim" with:
      """vim
      runtime! plugin/foo.vim
      describe 'g:foo'
        it 'is equal to 3'
          Expect g:foo == 3
        end
      end
      """
    And an executable file named "spec/sh.t" with:
      """bash
      #!/bin/bash
      echo 'ok 1'
      echo '1..1'
      """
    When I run `vim-flavor test spec`
    Then it should pass with regexp:
      """
      -------- Preparing dependencies
      Checking versions...
        Use kana/vim-vspec ... 1.1.0
      Deploying plugins...
        kana/vim-vspec 1.1.0 ... done
      Completed.
      -------- Testing a Vim plugin
      spec/sh.t .. ok
      All tests successful.
      Files=1, Tests=1,  \d+ wallclock secs .*
      Result: PASS
      spec/basics.vim .. ok
      All tests successful.
      Files=1, Tests=1,  \d+ wallclock secs .*
      Result: PASS
      """
    And a lockfile is created with:
      """
      kana/vim-vspec (1.1.0)
      """
    And a dependency "kana/vim-vspec" is stored in ".vim-flavor/deps"
