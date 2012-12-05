@typical_usage
Feature: Uninstall Vim plugins
  In order to automate boring steps,
  as a lazy Vim user,
  I want to use a declarative way to delete Vim plugins from my configuration.

  Background:
    Given a repository "foo" with versions "1.0.0 1.0.1 1.0.2"
    And a repository "bar" with versions "2.0.0 2.0.1 2.0.2"

  Scenario: Install after deleting some flavors in flavorfile
    Given a flavorfile with:
      """ruby
      flavor '$foo_uri'
      flavor '$bar_uri'
      """
    And I run `vim-flavor install`
    And a flavor "$foo_uri" version "1.0.2" is deployed to "$home/.vim"
    When I edit the flavorfile as:
      """ruby
      flavor '$bar_uri'
      """
    And I run `vim-flavor install`
    Then it should pass
    And a lockfile is created with:
      """
      $bar_uri (2.0.2)
      """
    And a bootstrap script is created in "$home/.vim"
    And a flavor "$bar_uri" version "2.0.2" is deployed to "$home/.vim"
    But a flavor "$foo_uri" is not deployed to "$home/.vim"
