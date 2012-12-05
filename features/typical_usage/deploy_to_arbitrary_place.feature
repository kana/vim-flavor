@typical_usage
Feature: Deploy Vim plugins to a non-standard directory
  In order to provide flexibility,
  as a lazy Vim user,
  I want to deploy Vim plugins to arbitrary place.

  Background:
    Given a repository "foo" with versions "1.0.0 1.0.1 1.0.2"

  Scenario: Install to specified vimfiles path which does not exist
    Given a flavorfile with:
      """ruby
      flavor '$foo_uri'
      """
    And a directory named "my-vimfiles" should not exist
    When I run `vim-flavor install --vimfiles-path=my-vimfiles`
    Then it should pass
    And a lockfile is created with:
      """
      $foo_uri (1.0.2)
      """
    And a bootstrap script is created in "my-vimfiles"
    And a flavor "$foo_uri" version "1.0.2" is deployed to "my-vimfiles"
