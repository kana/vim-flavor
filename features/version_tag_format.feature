Feature: Version tag format
  In order to use proper versions of Vim plugins,
  as a lazy Vim user,
  I want to use only tags which are formatted as versions.

  Scenario: With tags in the style of "X.Y.Z"
    Given a repository "foo" with versions "1 1.2 1.2.3"
    And a flavorfile with:
      """ruby
      flavor '$foo_uri'
      """
    When I run `vim-flavor install`
    Then it should pass
    And a lockfile is created with:
      """
      $foo_uri (1.2.3)
      """
    And a bootstrap script is created in "$home/.vim"
    And a flavor "$foo_uri" version "1.2.3" is deployed to "$home/.vim"

  Scenario: Without valid tags
    Given a repository "foo" with versions "abc def ghi"
    And a flavorfile with:
      """ruby
      flavor '$foo_uri'
      """
    When I run `vim-flavor install`
    Then it should fail with template:
      """
      Checking versions...
        Use $foo_uri ... failed
      """
    And it should fail with regexp:
      """
      There is no valid version
      """
    And a lockfile is not created
    And a bootstrap script is not created in "$home/.vim"
    And a flavor "$foo_uri" is not deployed to "$home/.vim"

  Scenario: Without tags
    Given a repository "foo"
    And a flavorfile with:
      """ruby
      flavor '$foo_uri'
      """
    When I run `vim-flavor install`
    Then it should fail with template:
      """
      Checking versions...
        Use $foo_uri ... failed
      """
    And it should fail with regexp:
      """
      There is no valid version
      """
    And a lockfile is not created
    And a bootstrap script is not created in "$home/.vim"
    And a flavor "$foo_uri" is not deployed to "$home/.vim"
