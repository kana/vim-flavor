@typical_usage
Feature: Upgrade Vim plugins
  In order to automate boring steps,
  as a lazy Vim user,
  I want to use a declarative way to upgrade my favorite Vim plugins.

  Background:
    Given a repository "foo" with versions "1.0.0 1.0.1 1.0.2"

  Scenario: Upgrade with lockfile
    Given a flavorfile with:
      """ruby
      flavor '$foo_uri'
      """
    And a lockfile with:
      """
      $foo_uri (1.0.0)
      """
    When I run `vim-flavor upgrade`
    Then it should pass
    And the lockfile is updated with:
      """
      $foo_uri (1.0.2)
      """
    And a bootstrap script is created in "$home/.vim"
    And a flavor "$foo_uri" version "1.0.2" is deployed to "$home/.vim"
