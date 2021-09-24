Feature: Flavorfile
  In order to gradually update existing Vim plugins,
  as a lazy Vim user,
  I want to reuse Vim plugins which contain old name of flavorfiles without problems.

  Scenario: User has old name of flavorfile is warned
    Given a repository "foo" with versions "1.0.0 1.0.1 1.0.2"
    And an old name flavorfile with:
      """ruby
      flavor '$foo_uri'
      """
    When I run `vim-flavor install`
    Then it should pass with template:
      """
      Warning: Rename VimFlavor to Flavorfile.  VimFlavor wll be ignored in future version.
      Checking versions...
        Use $foo_uri ... 1.0.2
      Deploying plugins...
        $foo_uri 1.0.2 ... done
      Completed.
      """
    And a lockfile is created with:
      """
      $foo_uri (1.0.2)
      """
    And a flavor "$foo_uri" version "1.0.2" is deployed to "$home/.vim"

  Scenario: User has both new and old name of flavorfile is warned
    Given a repository "foo" with versions "1.0.0 1.0.1 1.0.2"
    And a repository "bar" with versions "2.0.0 2.0.1 2.0.2"
    And a flavorfile with:
      """ruby
      flavor '$bar_uri'
      """
    And an old name flavorfile with:
      """ruby
      flavor '$foo_uri'
      """
    When I run `vim-flavor install`
    Then it should pass with template:
      """
      Warning: Delete VimFlavor.  Flavorfile is being read instead.
      Checking versions...
        Use $bar_uri ... 2.0.2
      Deploying plugins...
        $bar_uri 2.0.2 ... done
      Completed.
      """
    And a lockfile is created with:
      """
      $bar_uri (2.0.2)
      """
      And a flavor "$foo_uri" is not deployed to "$home/.vim"
    And a flavor "$bar_uri" version "2.0.2" is deployed to "$home/.vim"

  Scenario: Plugin contains old name of flavorfile is not warned
    Given a repository "foo" with versions "1.0.0 1.0.1 1.0.2" and an old name flavorfile:
      """ruby
      # No dependencies
      """
    And a flavorfile with:
      """ruby
      flavor '$foo_uri'
      """
    When I run `vim-flavor install`
    Then it should pass with template:
      """
      Checking versions...
        Use $foo_uri ... 1.0.2
      Deploying plugins...
        $foo_uri 1.0.2 ... done
      Completed.
      """
    And a lockfile is created with:
      """
      $foo_uri (1.0.2)
      """
    And a flavor "$foo_uri" version "1.0.2" is deployed to "$home/.vim"

  Scenario: Testing a Vim plugin with old name flavorfile is warned
    Given a repository "kana/vim-vspec" from offline cache
    And an old name flavorfile with:
      """ruby
      # No dependencies
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
    When I run `vim-flavor test`
    Then it should pass with regexp:
      """
      -------- Preparing dependencies
      Warning: Rename VimFlavor to Flavorfile.  VimFlavor wll be ignored in future version.
      Checking versions...
        Use kana/vim-vspec ... v?\d+\.\d+(\.\d+)?
      Deploying plugins...
        kana/vim-vspec v?\d+.\d+(\.\d+)? ... done
      Completed.
      -------- Testing a Vim plugin
      t/basics.vim .. ok
      All tests successful.
      Files=1, Tests=1,  \d+ wallclock secs .*
      Result: PASS
      """
    And a lockfile is created and matches with:
      """
      kana/vim-vspec \(v?\d+.\d+(\.\d+)?\)
      """
    And a dependency "kana/vim-vspec" is stored in ".vim-flavor/pack/flavors/start"

  Scenario: Testing a Vim plugin with both new and old name flavorfile is warned
    Given a repository "kana/vim-vspec" from offline cache
    And a flavorfile with:
      """ruby
      # No dependencies
      """
    And an old name flavorfile with:
      """ruby
      # No dependencies
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
    When I run `vim-flavor test`
    Then it should pass with regexp:
      """
      -------- Preparing dependencies
      Warning: Delete VimFlavor.  Flavorfile is being read instead.
      Checking versions...
        Use kana/vim-vspec ... v?\d+.\d+(\.\d+)?
      Deploying plugins...
        kana/vim-vspec v?\d+.\d+(\.\d+)? ... done
      Completed.
      -------- Testing a Vim plugin
      t/basics.vim .. ok
      All tests successful.
      Files=1, Tests=1,  \d+ wallclock secs .*
      Result: PASS
      """
    And a lockfile is created and matches with:
      """
      kana/vim-vspec \(v?\d+.\d+(\.\d+)?\)
      """
    And a dependency "kana/vim-vspec" is stored in ".vim-flavor/pack/flavors/start"
