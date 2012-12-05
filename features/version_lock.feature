Feature: Version lock
  In order to use the same configuration on every machine,
  as a lazy Vim user,
  I want to keep versions of Vim plugins which I installed before.

  Background:
    Given a repository "foo" with versions "1.0.0 1.0.1 1.0.2"

  Scenario: Install with lockfile
    Given a flavorfile with:
      """ruby
      flavor '$foo_uri'
      """
    And a lockfile with:
      """
      $foo_uri (1.0.0)
      """
    When I run `vim-flavor install`
    Then it should pass
    And the lockfile is updated with:
      """
      $foo_uri (1.0.0)
      """
    And a bootstrap script is created in "$home/.vim"
    And a flavor "$foo_uri" version "1.0.0" is deployed to "$home/.vim"
