Feature: Version tag format
  In order to use proper versions of Vim plugins,
  as a lazy Vim user,
  I want to use only tags which are formatted as versions.

  # Points:
  # - Use ~> to check versions are properly compared.
  # - Install twice to check whether a lockfile is properly read or not.

  Scenario: With tags in the style of "X.Y.Z"
    Given a repository "foo" with versions "1.0 1.1 1.2 1.2.3"
    And a flavorfile with:
      """ruby
      flavor '$foo_uri', '~> 1.1'
      """
    When I run `vim-flavor install`
    Then it should pass with template:
      """
      Checking versions...
        Use $foo_uri ... 1.2.3
      Deploying plugins...
        $foo_uri 1.2.3 ... done
      Completed.
      """
    And a lockfile is created with:
      """
      $foo_uri (1.2.3)
      """
    And a bootstrap script is created in "$home/.vim"
    And a flavor "$foo_uri" version "1.2.3" is deployed to "$home/.vim"
    When I run `vim-flavor install`
    Then it should pass with template:
      """
      Checking versions...
        Use $foo_uri ... 1.2.3
      Deploying plugins...
        $foo_uri 1.2.3 ... skipped (already deployed)
      Completed.
      """

  Scenario: With tags in the style of "vX.Y.Z"
    Given a repository "foo" with versions "v1.0 v1.1 v1.2 v1.2.3"
    And a flavorfile with:
      """ruby
      flavor '$foo_uri', '~> 1.1'
      """
    When I run `vim-flavor install`
    Then it should pass with template:
      """
      Checking versions...
        Use $foo_uri ... v1.2.3
      Deploying plugins...
        $foo_uri v1.2.3 ... done
      Completed.
      """
    And a lockfile is created with:
      """
      $foo_uri (v1.2.3)
      """
    And a bootstrap script is created in "$home/.vim"
    And a flavor "$foo_uri" version "v1.2.3" is deployed to "$home/.vim"
    When I run `vim-flavor install`
    Then it should pass with template:
      """
      Checking versions...
        Use $foo_uri ... v1.2.3
      Deploying plugins...
        $foo_uri v1.2.3 ... skipped (already deployed)
      Completed.
      """

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
