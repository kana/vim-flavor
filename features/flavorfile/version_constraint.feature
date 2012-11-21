Feature: Version constraint
  In order to use Vim plugins which are compatible with my configuration,
  as a lazy Vim user,
  I want to declare desirable versions of Vim plugins.

  Note that vim-flavor assumes that plugins follow [the versioning pocilies of
  RubyGems](http://docs.rubygems.org/read/chapter/7#page26), to determine
  compatibility of plugins.  See also [Philosophy](philosophy) for the details.

  Background:
    Given a temporary directory called 'tmp'
    And a home directory called 'home' in '$tmp/home'
    And a repository 'foo' with versions '1.0 1.1 1.2 2.0'

  Scenario: Declare using the latest version of a Vim plugin
    Given flavorfile
      """ruby
      flavor '$foo_uri'
      """
    When I run `vim-flavor install`
    Then I get lockfile
      """
      $foo_uri (2.0)
      """
    And I get a bootstrap script in '$home/.vim'
    And I get flavor '$foo_uri' with '2.0' in '$home/.vim'

  Scenario: Declare using a Vim plugin not older than a specific version
    Given flavorfile
      """ruby
      flavor '$foo_uri', '>= 1.1'
      """
    When I run `vim-flavor install`
    Then I get lockfile
      """
      $foo_uri (2.0)
      """
    And I get a bootstrap script in '$home/.vim'
    And I get flavor '$foo_uri' with '2.0' in '$home/.vim'

  Scenario: Declare using the latest and compatible version of a Vim plugin
    Given flavorfile
      """ruby
      flavor '$foo_uri', '~> 1.0'
      """
    When I run `vim-flavor install`
    Then I get lockfile
      """
      $foo_uri (1.2)
      """
    And I get a bootstrap script in '$home/.vim'
    And I get flavor '$foo_uri' with '1.2' in '$home/.vim'
