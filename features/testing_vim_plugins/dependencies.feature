Feature: Dependencies
  In order to easily test Vim plugins with dependencies,
  As a lazy Vim user,
  I want to hide details to do proper testing.

  Background:
    Given a temporary directory called 'tmp'
    And a home directory called 'home' in '$tmp/home'
    And a repository 'kana/vim-vspec' from offline cache
    And a repository 'kana/vim-textobj-user' from offline cache

  Scenario: Testing a Vim plugin with dependencies
    Given flavorfile
      """
      flavor 'kana/vim-textobj-user', '~> 0.3'
      """
    And a file called '$tmp/plugin/textobj/date.vim'
      """
      call textobj#user#plugin('date', {
      \   '-': {
      \     '*pattern*': '\v<\d{4}-\d{2}-\d{2}>',
      \     'select': ['ad', 'id'],
      \   }
      \ })
      """
    And a file called '$tmp/t/basics.vim'
      """
      " Tests are written with vim-vspec.
      runtime! plugin/textobj/date.vim
      describe 'Text object: date'
        it 'is available in Visual mode'
          Expect maparg('ad', 'v') != ''
        end
      end
      """
    When I run `vim-flavor test`
    Then it succeeds
    And it outputs progress like
      """
      -------- Preparing dependencies
      Checking versions...
        Use kana/vim-textobj-user ... 0.3.12
        Use kana/vim-vspec ... 1.1.0
      Deploying plugins...
        kana/vim-textobj-user 0.3.12 ... done
        kana/vim-vspec 1.1.0 ... done
      -------- Testing a Vim plugin
      Files=0, Tests=0,  \d+ wallclock secs .*
      Result: NOTESTS
      t/basics.vim .. ok
      All tests successful.
      Files=1, Tests=1,  \d+ wallclock secs .*
      Result: PASS
      """
    And I get lockfile
      """
      kana/vim-textobj-user (0.3.12)
      kana/vim-vspec (1.1.0)
      """
    And it stores a dependency 'kana/vim-vspec' in '$tmp/.vim-flavor/deps'
    And it stores a dependency 'kana/vim-textobj-user' in '$tmp/.vim-flavor/deps'
