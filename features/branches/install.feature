Feature: Install Vim plugins with specific branches
  In order to try out proposed changes which are not released yet,
  as a lazy Vim user,
  I want to track the latest revision of a specific branch.

  Background:
    Given a repository "foo" with versions "1.0.0 1.0.1 1.0.2"

  Scenario: Install a new plugin from scratch
    Given a flavorfile with:
      """ruby
      flavor '$foo_uri', branch: 'master'
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

  Scenario: Install a plugin according to a lockfile
    Given a flavorfile with:
      """ruby
      flavor '$foo_uri', branch: 'master'
      """
    And I run `vim-flavor install`
    And a lockfile is created with:
      """
      $foo_uri ($foo_rev_102 at master)
      """
    And "foo" version "1.0.3" is released
    When I run `vim-flavor install`
    Then it should pass with template:
      """
      Checking versions...
        Use $foo_uri ... $foo_rev_102 at master
      Deploying plugins...
        $foo_uri $foo_rev_102 at master ... skipped (already deployed)
      Completed.
      """
    And a bootstrap script is created in "$home/.vim"
    And a flavor "$foo_uri" version "1.0.2" is deployed to "$home/.vim"
