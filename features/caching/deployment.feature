Feature: Deployment
  In order to finish deployment as fast as possible,
  as a lazy Vim user,
  I want to skip plugins which are already deployed with proper versions.

  Background:
    Given a repository "foo" with versions "1.0 1.1 1.2"
    And a flavorfile with:
      """ruby
      flavor '$foo_uri', '~> 1.0'
      """
  Scenario: Deploy plugins which are not deployed yet
    Given a flavor "$foo_uri" is not deployed to "$home/.vim"
    When I run `vim-flavor install`
    Then it should pass with template:
      """
      Checking versions...
        Use $foo_uri ... 1.2
      Deploying plugins...
        $foo_uri 1.2 ... done
      Completed.
      """
    And a flavor "$foo_uri" version "1.2" is deployed to "$home/.vim"

  Scenario: Skip plugins which are already deployed with proper versions
    Given I run `vim-flavor install`
    And a flavor "$foo_uri" version "1.2" is deployed to "$home/.vim"
    When I create a file named "abc" in "$foo_uri" deployed to "$home/.vim"
    And I run `vim-flavor install`
    Then it should pass with template:
      """
      Checking versions...
        Use $foo_uri ... 1.2
      Deploying plugins...
        $foo_uri 1.2 ... skipped (already deployed)
      Completed.
      """
    And a flavor "$foo_uri" version "1.2" is deployed to "$home/.vim"
    And a file named "abc" should exist in "$foo_uri" deployed to "$home/.vim"

  Scenario: Redeploy plugins if their versions differ from deployed ones
    Given a lockfile with:
      """
      $foo_uri (1.0)
      """
    And I run `vim-flavor install`
    And a flavor "$foo_uri" version "1.0" is deployed to "$home/.vim"
    When I create a file named "abc" in "$foo_uri" deployed to "$home/.vim"
    And I edit the lockfile as:
      """
      $foo_uri (1.1)
      """
    And I run `vim-flavor install`
    Then it should pass with template:
      """
      Checking versions...
        Use $foo_uri ... 1.1
      Deploying plugins...
        $foo_uri 1.1 ... done
      Completed.
      """
    And a flavor "$foo_uri" version "1.1" is deployed to "$home/.vim"
    And a file named "abc" should not exist in "$foo_uri" deployed to "$home/.vim"
