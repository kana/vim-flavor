Feature: Lockfile
  In order to gradually update existing configuration,
  as a lazy Vim user,
  I want to reuse version lock information before upgrading vim-flavor.

  Scenario: User has old name of lockfile is warned
    Given a repository "foo" with versions "1.0.0 1.0.1 1.0.2"
    And a flavorfile with:
      """ruby
      flavor '$foo_uri'
      """
    And an old name lockfile with:
      """
      $foo_uri (1.0.1)
      """
    When I run `vim-flavor install`
    Then it should pass with template:
      """
      Warning: VimFlavor.lock is being read.  Flavorfile.lock will be created.
      Checking versions...
        Use $foo_uri ... 1.0.1
      Deploying plugins...
        $foo_uri 1.0.1 ... done
      Completed.
      Warning: Flavorfile.lock has been created.  Delete VimFlavor.lock.  It is no longer used.
      """
    And a lockfile is updated and matches with:
      """
      $foo_uri (1.0.1)
      """
    And a flavor "$foo_uri" version "1.0.1" is deployed to "$home/.vim"

  Scenario: User has both new and old name of lockfile is warned
    Given a repository "foo" with versions "1.0.0 1.0.1 1.0.2"
    And a flavorfile with:
      """ruby
      flavor '$foo_uri'
      """
    And a lockfile with:
      """
      $foo_uri (1.0.0)
      """
    And an old name lockfile with:
      """
      $foo_uri (1.0.1)
      """
    When I run `vim-flavor install`
    Then it should pass with template:
      """
      Warning: Delete VimFlavor.lock.  It is no longer used.
      Checking versions...
        Use $foo_uri ... 1.0.0
      Deploying plugins...
        $foo_uri 1.0.0 ... done
      Completed.
      """
    And a lockfile is updated and matches with:
      """
      $foo_uri (1.0.0)
      """
    And a flavor "$foo_uri" version "1.0.0" is deployed to "$home/.vim"
