Feature: Groups
  In order to deploy a specific set of Vim plugins,
  as a lazy Vim user,
  I want to declare groups of flavors.

  Background:
    Given a repository "foo" with versions "1.0 1.1 1.2"
    And a repository "bar" with versions "2.0 2.1 2.2"

  Scenario: Install only runtime dependencies
    Given a flavorfile with:
      """ruby
      flavor '$foo_uri', :group => :runtime
      flavor '$bar_uri', :group => :development
      """
    When I run `vim-flavor install`
    Then it should pass
    And a lockfile is created with:
      """
      $foo_uri (1.2)
      """
    And a bootstrap script is created in "$home/.vim"
    And a flavor "$foo_uri" version "1.2" is deployed to "$home/.vim"
    But a flavor "$bar_uri" is not deployed to "$home/.vim"

  Scenario: The default group
    Given a flavorfile with:
      """ruby
      flavor '$foo_uri'
      flavor '$bar_uri', :group => :development
      """
    When I run `vim-flavor install`
    Then it should pass
    And a lockfile is created with:
      """
      $foo_uri (1.2)
      """
    And a bootstrap script is created in "$home/.vim"
    And a flavor "$foo_uri" version "1.2" is deployed to "$home/.vim"
    But a flavor "$bar_uri" is not deployed to "$home/.vim"

  Scenario: Group a bunch of flavors at once
    Given a flavorfile with:
      """ruby
      group :development do
        flavor '$foo_uri'
        flavor '$bar_uri'
      end
      """
    When I run `vim-flavor install`
    Then it should pass
    And a lockfile is created with:
      """
      """
    And a bootstrap script is created in "$home/.vim"
    But a flavor "$foo_uri" is not deployed to "$home/.vim"
    But a flavor "$bar_uri" is not deployed to "$home/.vim"
