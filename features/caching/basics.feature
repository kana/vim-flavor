Feature: Basics
  In order to finish deployment as fast as possible,
  as a lazy Vim user,
  I want to cache repositories of plugins which are installed before.

  Background:
    Given a repository "foo" with versions "1.0.0 1.0.1 1.0.2"
    And a flavorfile with:
      """ruby
      flavor '$foo_uri', '~> 1.0'
      """
    And I run `vim-flavor install`
    And I disable network to the original repository of "foo"

  Scenario: Install plugins - locked and compatible with new flavorfile
    Given I delete the directory "home/.vim"
    When I run `vim-flavor install`
    Then it should pass
    And a lockfile is created with:
      """
      $foo_uri (1.0.2)
      """
    And a flavor "$foo_uri" version "1.0.2" is deployed to "$home/.vim"

  Scenario: Install plugins - locked but incompatible with new flavorfile
    Given I edit the flavorfile as:
      """ruby
      flavor '$foo_uri', '~> 2.0'
      """
    When I run `vim-flavor install`
    Then it should fail with regexp:
      """
      fatal: \S+ does not appear to be a git repository
      """

  Scenario: Install plugins - not locked
    Given I delete the lockfile
    When I run `vim-flavor install`
    Then it should fail with regexp:
      """
      fatal: \S+ does not appear to be a git repository
      """

  Scenario: Updating plugins
    When I run `vim-flavor update`
    Then it should fail with regexp:
      """
      fatal: \S+ does not appear to be a git repository
      """
