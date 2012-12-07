Feature: Edge cases
  In order to use the same configuration across multiple environments,
  as a lazy Vim user,
  I want to properly update cached repositories of plugins.

  Scenario: Using `vim-flavor` on multiple environments
    Given a repository "foo" with versions "1.0 1.1 1.2"
    And a flavorfile with:
      """ruby
      flavor '$foo_uri', '~> 1.0'
      """
    And I run `vim-flavor install`
    And a lockfile is created with:
      """
      $foo_uri (1.2)
      """
    And a flavor "$foo_uri" version "1.2" is deployed to "$home/.vim"
    And "foo" version "1.3" is released
    And "foo" version "1.4" is released
    And I copy a new lockfile from another machine with:
      """
      $foo_uri (1.3)
      """
    And "$foo_uri" version "1.3" is not cached
    When I run `vim-flavor install`
    Then it should pass
    And the lockfile is updated with:
      """
      $foo_uri (1.3)
      """
    And a flavor "$foo_uri" version "1.3" is deployed to "$home/.vim"
    And "$foo_uri" version "1.3" is cached
