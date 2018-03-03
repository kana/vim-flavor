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
