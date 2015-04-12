Feature: Failures
  In order to automate varisous processes about testing Vim plugins,
  As a lazy Vim user,
  I want to get a proper exit status according to test results.

  Background:
    Given a repository "kana/vim-vspec" from offline cache

  Scenario: Failed test cases
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
      runtime! plugin/foo.vim
      describe 'g:foo'
        it 'is equal to 5'
          Expect g:foo == 5
        end
      end
      """
    When I run `vim-flavor test`
    Then it should fail with regexp:
      """
      -------- Preparing dependencies
      Checking versions...
        Use kana/vim-vspec ... 1\.\d+(\.\d+)?
      Deploying plugins...
        kana/vim-vspec 1\.\d+(\.\d+)? ... done
      Completed.
      -------- Testing a Vim plugin
      t/basics.vim ..\s
      not ok 1 - g:foo is equal to 5
      # Expected g:foo == 5
      #       Actual value: 3
      #     Expected value: 5
      Failed 1/1 subtests 

      Test Summary Report
      -------------------
      t/basics.vim \(Wstat: 0 Tests: 1 Failed: 1\)
        Failed test:  1
      Files=1, Tests=1,  0 wallclock secs (.*)
      Result: FAIL
      """
    And the output should not contain:
      """
      :in `test':
      """
    And a lockfile is created and matches with:
      """
      kana/vim-vspec \(1\.\d+(\.\d+)?\)
      """
    And a dependency "kana/vim-vspec" is stored in ".vim-flavor/deps"
