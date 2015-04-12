Feature: Specifying test scripts
  In order to run test scripts not in the standard `t` directory
  or to run specific test scripts,
  As a lazy Vim user,
  I want to specify test scripts to be run,
  like `vim-flavor test FILES-OR-DIRECTOREIS`.

  Background:
    Given a repository "kana/vim-vspec" from offline cache
    And a flavorfile with:
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

  Scenario: Running test scripts in non-standard location
    When I run `vim-flavor test spec`
    Then it should pass with regexp:
      """
      -------- Preparing dependencies
      Checking versions...
        Use kana/vim-vspec ... 1\.\d+(\.\d+)?
      Deploying plugins...
        kana/vim-vspec 1\.\d+(\.\d+)? ... done
      Completed.
      -------- Testing a Vim plugin
      spec/basics.vim .. ok
      spec/sh.t ........ ok
      All tests successful.
      Files=2, Tests=2,  \d+ wallclock secs .*
      Result: PASS
      """
    And a lockfile is created and matches with:
      """
      kana/vim-vspec \(1\.\d+(\.\d+)?\)
      """
    And a dependency "kana/vim-vspec" is stored in ".vim-flavor/deps"

  Scenario: Running a specific `.vim` test script
    When I run `vim-flavor test spec/basics.vim`
    Then it should pass with regexp:
      """
      -------- Preparing dependencies
      Checking versions...
        Use kana/vim-vspec ... 1\.\d+(\.\d+)?
      Deploying plugins...
        kana/vim-vspec 1\.\d+(\.\d+)? ... done
      Completed.
      -------- Testing a Vim plugin
      spec/basics.vim .. ok
      All tests successful.
      Files=1, Tests=1,  \d+ wallclock secs .*
      Result: PASS
      """
    And a lockfile is created and matches with:
      """
      kana/vim-vspec \(1\.\d+(\.\d+)?\)
      """
    And a dependency "kana/vim-vspec" is stored in ".vim-flavor/deps"

  Scenario: Running a specific `.t` test script
    When I run `vim-flavor test spec/sh.t`
    Then it should pass with regexp:
      """
      -------- Preparing dependencies
      Checking versions...
        Use kana/vim-vspec ... 1\.\d+(\.\d+)?
      Deploying plugins...
        kana/vim-vspec 1\.\d+(\.\d+)? ... done
      Completed.
      -------- Testing a Vim plugin
      spec/sh.t .. ok
      All tests successful.
      Files=1, Tests=1,  \d+ wallclock secs .*
      Result: PASS
      """
    And a lockfile is created and matches with:
      """
      kana/vim-vspec \(1\.\d+(\.\d+)?\)
      """
    And a dependency "kana/vim-vspec" is stored in ".vim-flavor/deps"
