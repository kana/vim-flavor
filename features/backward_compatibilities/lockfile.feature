Feature: Lockfile
  In order to avoid unexpected result and confusion,
  as a lazy Vim user,
  I want to stop vim-flavor process if obsolete file still exists.

  Scenario: User has old name of lockfile
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
    Then it should fail with template:
      """
      Error: VimFlavor.lock is no longer used.  Rename it to Flavorfile.lock.
      """
    And a lockfile is not created
    And a flavor "$foo_uri" is not deployed to "$home/.vim"
