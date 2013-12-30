Feature: Version constraint
  In order to use Vim plugins which are compatible with my configuration,
  as a lazy Vim user,
  I want to declare desirable versions of Vim plugins.

  Note that vim-flavor assumes that plugins follow [the versioning policies of
  RubyGems](http://docs.rubygems.org/read/chapter/7#page26), to determine
  compatibility of plugins.  See also [Philosophy](../philosophy) for the
  details.

  Background:
    Given a repository "foo" with versions "1.0 1.1 1.2 2.0"

  Scenario: Declare using the latest version of a Vim plugin
    Given a flavorfile with:
      """ruby
      flavor '$foo_uri'
      """
    When I run `vim-flavor install`
    Then it should pass
    And a lockfile is created with:
      """
      $foo_uri (2.0)
      """
    And a bootstrap script is created in "$home/.vim"
    And a flavor "$foo_uri" version "2.0" is deployed to "$home/.vim"

  Scenario: Declare using a Vim plugin not older than a specific version
    Given a flavorfile with:
      """ruby
      flavor '$foo_uri', '>= 1.1'
      """
    When I run `vim-flavor install`
    Then it should pass
    And a lockfile is created with:
      """
      $foo_uri (2.0)
      """
    And a bootstrap script is created in "$home/.vim"
    And a flavor "$foo_uri" version "2.0" is deployed to "$home/.vim"

  Scenario: Declare using the latest and compatible version of a Vim plugin
    Given a flavorfile with:
      """ruby
      flavor '$foo_uri', '~> 1.0'
      """
    When I run `vim-flavor install`
    Then it should pass
    And a lockfile is created with:
      """
      $foo_uri (1.2)
      """
    And a bootstrap script is created in "$home/.vim"
    And a flavor "$foo_uri" version "1.2" is deployed to "$home/.vim"
