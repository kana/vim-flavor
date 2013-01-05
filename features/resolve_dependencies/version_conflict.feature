Feature: Version conflict
  In order to avoid using Vim with a broken configuration,
  as a lazy Vim user,
  I want to stop installation as soon as possible.

  Scenario: Two or more plugins require incompatible versions of the same plugin
    Given a repository "foo" with versions "1.0 1.1 2.0 2.1"
    And a repository "bar" with versions "1.0 1.1 2.0 2.1" and a flavorfile:
      """ruby
      flavor '$foo_uri', '~> 1.0'
      """
    And a repository "qux" with versions "1.0 1.1 2.0 2.1" and a flavorfile:
      """ruby
      flavor '$foo_uri', '~> 2.0'
      """
    And a flavorfile with:
      """ruby
      flavor '$bar_uri'
      flavor '$qux_uri'
      """
    When I run `vim-flavor install`
    Then it should fail with template:
      """
      Checking versions...
        Use $bar_uri ... 2.1
          Use $foo_uri ... 1.1
        Use $qux_uri ... 2.1
          Use $foo_uri ... 2.1
      Found incompatible declarations:
        $foo_uri ~> 1.0 is required by $bar_uri
        $foo_uri ~> 2.0 is required by $qux_uri
      Please resolve the conflict.
      """
    And a bootstrap script is not created in "$home/.vim"
    And a flavor "$foo_uri" is not deployed to "$home/.vim"
    And a flavor "$bar_uri" is not deployed to "$home/.vim"
    And a flavor "$qux_uri" is not deployed to "$home/.vim"

  Scenario: Flavorfile and a plugin require incompatible versions of the same plugin
    Given a repository "foo" with versions "1.0 1.1 2.0 2.1"
    And a repository "bar" with versions "1.0 1.1 2.0 2.1" and a flavorfile:
      """ruby
      flavor '$foo_uri', '~> 1.0'
      """
    And a flavorfile with:
      """ruby
      flavor '$bar_uri'
      flavor '$foo_uri', '>= 2.0'
      """
    When I run `vim-flavor install`
    Then it should fail with template:
      """
      Checking versions...
        Use $bar_uri ... 2.1
          Use $foo_uri ... 1.1
        Use $foo_uri ... 2.1
      Found incompatible declarations:
        $foo_uri ~> 1.0 is required by $bar_uri
        $foo_uri >= 2.0 is required by you
      Please resolve the conflict.
      """
    And a bootstrap script is not created in "$home/.vim"
    And a flavor "$foo_uri" is not deployed to "$home/.vim"
    And a flavor "$bar_uri" is not deployed to "$home/.vim"
