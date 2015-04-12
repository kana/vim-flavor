Feature: Typical usage
  In order to easily test Vim plugins,
  As a lazy Vim user,
  I want to hide details to do proper testing.

  Background:
    Given a repository "kana/vim-vspec" from offline cache

  Scenario: Testing a Vim plugin without any dependency
    Given a flavorfile with:
      """ruby
      # No dependency
      """
    And a file named "plugin/foo.vim" with:
      """vim
      let g:foo = 3
      """
    And a file named "t/basics.vim" with:
      """vim
      " Tests are written with vim-vspec.
      runtime! plugin/foo.vim
      describe 'g:foo'
        it 'is equal to 3'
          Expect g:foo == 3
        end
      end
      """
    And an executable file named "t/sh.t" with:
      """bash
      #!/bin/bash
      # It is also possible to write tests with arbitrary tools.
      # Such tests must output results in Test Anything Protocol.
      echo 'ok 1'
      echo '1..1'
      """
    When I run `vim-flavor test`
    Then it should pass with regexp:
      """
      -------- Preparing dependencies
      Checking versions...
        Use kana/vim-vspec ... 1\.\d+(\.\d+)?
      Deploying plugins...
        kana/vim-vspec 1\.\d+(\.\d+)? ... done
      Completed.
      -------- Testing a Vim plugin
      t/basics.vim .. ok
      t/sh.t ........ ok
      All tests successful.
      Files=2, Tests=2,  \d+ wallclock secs .*
      Result: PASS
      """
    And a lockfile is created and matches with:
      """
      kana/vim-vspec \(1\.\d+(\.\d+)?\)
      """
    And a dependency "kana/vim-vspec" is stored in ".vim-flavor/deps"
