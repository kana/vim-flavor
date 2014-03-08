Feature: Changing tracking branches
  In order to try out another branch instead of the currently used one,
  as a lazy Vim user,
  I want to use the latest revision of the new branch.

  Background:
    Given a repository "foo" with versions "1.0.0 1.0.1 1.0.2"

  Scenario: Changing tracking branches
    Given a flavorfile with:
      """ruby
      flavor '$foo_uri', branch: 'master'
      """
    And a lockfile with:
      """
      $foo_uri ($foo_rev_101 at experimental)
      """
    When I run `vim-flavor install`
    Then it should pass with template:
      """
      Checking versions...
        Use $foo_uri ... $foo_rev_102 at master
      Deploying plugins...
        $foo_uri $foo_rev_102 at master ... done
      Completed.
      """
    And a bootstrap script is created in "$home/.vim"
    And a flavor "$foo_uri" version "1.0.2" is deployed to "$home/.vim"

  Scenario: Use a branch instead of a version
    Given a flavorfile with:
      """ruby
      flavor '$foo_uri', branch: 'master'
      """
    And a lockfile with:
      """
      $foo_uri (1.0.1)
      """
    When I run `vim-flavor install`
    Then it should pass with template:
      """
      Checking versions...
        Use $foo_uri ... $foo_rev_102 at master
      Deploying plugins...
        $foo_uri $foo_rev_102 at master ... done
      Completed.
      """
    And a lockfile is created with:
      """
      $foo_uri ($foo_rev_102 at master)
      """
    And a bootstrap script is created in "$home/.vim"
    And a flavor "$foo_uri" version "1.0.2" is deployed to "$home/.vim"

  Scenario: Use a version instead of a branch
    Given a flavorfile with:
      """ruby
      flavor '$foo_uri', '~> 1.0.1'
      """
    And a lockfile with:
      """
      $foo_uri ($foo_rev_100 at master)
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
    And a bootstrap script is created in "$home/.vim"
    And a flavor "$foo_uri" version "1.0.2" is deployed to "$home/.vim"
