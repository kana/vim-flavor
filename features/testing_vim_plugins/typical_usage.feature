Feature: Typical usage
  In order to easily test Vim plugins,
  As a lazy Vim user,
  I want to hide details to do proper testing.

  Background:
    Given a temporary directory called 'tmp'
    And a home directory called 'home' in '$tmp/home'
    And a repository 'kana/vim-vspec' from offline cache

  Scenario: Testing a Vim plugin without any dependency
    Given flavorfile
      """
      # No dependency
      """
    And a file called '$tmp/plugin/foo.vim'
      """
      let g:foo = 3
      """
    And a file called '$tmp/t/basics.vim'
      """
      " Tests are written with vim-vspec.
      runtime! plugin/foo.vim
      describe 'g:foo'
        it 'is equal to 3'
          Expect g:foo == 3
        end
      end
      """
    And an executable called '$tmp/t/sh.t'
      """
      #!/bin/bash
      # It is also possible to write tests with arbitrary tools.
      # Such tests must output results in Test Anything Protocol.
      echo 'ok 1'
      echo '1..1'
      """
    When I run `vim-flavor test`
    Then it succeeds
    And it outputs progress like
      """
      -------- Preparing dependencies
      Checking versions...
        Use kana/vim-vspec ... 1.1.0
      Deploying plugins...
        kana/vim-vspec 1.1.0 ... done
      -------- Testing a Vim plugin
      t/sh.t .. ok
      All tests successful.
      Files=1, Tests=1,  \d+ wallclock secs .*
      Result: PASS
      t/basics.vim .. ok
      All tests successful.
      Files=1, Tests=1,  \d+ wallclock secs .*
      Result: PASS
      """
    And I get lockfile
      """
      kana/vim-vspec (1.1.0)
      """
    And it stores a dependency 'kana/vim-vspec' in '$tmp/.vim-flavor/deps'
