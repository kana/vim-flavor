Feature: Dependencies
  In order to easily test Vim plugins with dependencies,
  As a lazy Vim user,
  I want to hide details to do proper testing.

  Background:
    Given a repository "kana/vim-vspec" from offline cache
    And a repository "kana/vim-textobj-user" from offline cache

  Scenario: Testing a Vim plugin with dependencies
    Given a flavorfile with:
      """ruby
      flavor 'kana/vim-textobj-user', '~> 0.3'
      """
    And a file named "plugin/textobj/date.vim" with:
      """vim
      call textobj#user#plugin('date', {
      \   '-': {
      \     '*pattern*': '\v<\d{4}-\d{2}-\d{2}>',
      \     'select': ['ad', 'id'],
      \   }
      \ })
      """
    And a file named "t/basics.vim" with:
      """vim
      " Tests are written with vim-vspec.
      runtime! plugin/textobj/date.vim
      describe 'Text object: date'
        it 'is available in Visual mode'
          Expect maparg('ad', 'v') != ''
        end
      end
      """
    When I run `vim-flavor test`
    Then it should pass with regexp:
      """
      -------- Preparing dependencies
      Checking versions...
        Use kana/vim-textobj-user ... 0\.\d+(\.\d+)?
        Use kana/vim-vspec ... 1\.\d+(\.\d+)?
      Deploying plugins...
        kana/vim-textobj-user 0\.\d+(\.\d+)? ... done
        kana/vim-vspec 1\.\d+(\.\d+)? ... done
      Completed.
      -------- Testing a Vim plugin
      t/basics.vim .. ok
      All tests successful.
      Files=1, Tests=1,  \d+ wallclock secs .*
      Result: PASS
      """
    And a lockfile is created and matches with:
      """
      kana/vim-textobj-user \(0\.\d+(\.\d+)?\)
      kana/vim-vspec \(1\.\d+(\.\d+)?\)
      """
    And a dependency "kana/vim-vspec" is stored in ".vim-flavor/deps"
    And a dependency "kana/vim-textobj-user" is stored in ".vim-flavor/deps"
