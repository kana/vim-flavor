@typical_usage
Feature: Install Vim plugins
  In order to automate boring steps,
  as a lazy Vim user,
  I want to use a declarative way to start using new Vim plugins.

  Background:
    Given a repository "foo" with versions "1.0.0 1.0.1 1.0.2"

  Scenario: Install from scratch
    Given a flavorfile with:
      """ruby
      """
    When I edit the flavorfile as:
      """ruby
      flavor '$foo_uri'
      """
    And I run `vim-flavor install`
    Then it should pass
    And a lockfile is created with:
      """
      $foo_uri (1.0.2)
      """
    And a bootstrap script is created in "$home/.vim"
    And a flavor "$foo_uri" version "1.0.2" is deployed to "$home/.vim"
