@typical_usage
Feature: Update Vim plugins
  In order to automate boring steps,
  as a lazy Vim user,
  I want to use a declarative way to update my favorite Vim plugins.

  Background:
    Given a repository "foo" with versions "1.0.0 1.0.1 1.0.2"
    Given a repository "bar" with versions "1.0.0 1.0.1 1.0.2"
    Given a repository "baz" with versions "1.0.0 1.0.1 1.0.2"

  Scenario: Update all plugins
    Given a flavorfile with:
      """ruby
      flavor '$foo_uri'
      flavor '$bar_uri'
      flavor '$baz_uri'
      """
    And a lockfile with:
      """
      $bar_uri (1.0.0)
      $baz_uri (1.0.0)
      $foo_uri (1.0.0)
      """
    When I run `vim-flavor update`
    Then it should pass
    And the lockfile is updated with:
      """
      $bar_uri (1.0.2)
      $baz_uri (1.0.2)
      $foo_uri (1.0.2)
      """
    And a bootstrap script is created in "$home/.vim"
    And a flavor "$foo_uri" version "1.0.2" is deployed to "$home/.vim"
    And a flavor "$bar_uri" version "1.0.2" is deployed to "$home/.vim"
    And a flavor "$baz_uri" version "1.0.2" is deployed to "$home/.vim"

  Scenario: Update specific plugins
    Given a flavorfile with:
      """ruby
      flavor '$foo_uri'
      flavor '$bar_uri'
      flavor '$baz_uri'
      """
    And a lockfile with:
      """
      $bar_uri (1.0.0)
      $baz_uri (1.0.0)
      $foo_uri (1.0.0)
      """
    When I run `vim-flavor update $foo_uri $baz_uri` (variables expanded)
    Then it should pass
    And the lockfile is updated with:
      """
      $bar_uri (1.0.0)
      $baz_uri (1.0.2)
      $foo_uri (1.0.2)
      """
    And a bootstrap script is created in "$home/.vim"
    And a flavor "$foo_uri" version "1.0.2" is deployed to "$home/.vim"
    And a flavor "$bar_uri" version "1.0.0" is deployed to "$home/.vim"
    And a flavor "$baz_uri" version "1.0.2" is deployed to "$home/.vim"

  Scenario: Update by "upgrade", an alias of "update" for backward compatibility
    Given a flavorfile with:
      """ruby
      flavor '$foo_uri'
      flavor '$bar_uri'
      flavor '$baz_uri'
      """
    And a lockfile with:
      """
      $bar_uri (1.0.0)
      $baz_uri (1.0.0)
      $foo_uri (1.0.0)
      """
    When I run `vim-flavor upgrade`
    Then it should pass
    And the lockfile is updated with:
      """
      $bar_uri (1.0.2)
      $baz_uri (1.0.2)
      $foo_uri (1.0.2)
      """
    And a bootstrap script is created in "$home/.vim"
    And a flavor "$foo_uri" version "1.0.2" is deployed to "$home/.vim"
    And a flavor "$bar_uri" version "1.0.2" is deployed to "$home/.vim"
    And a flavor "$baz_uri" version "1.0.2" is deployed to "$home/.vim"
