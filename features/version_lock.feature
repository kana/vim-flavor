Feature: Version lock
  In order to use the same configuration on every machine,
  as a lazy Vim user,
  I want to keep versions of Vim plugins which I installed before.

  Background:
    Given a temporary directory called 'tmp'
    And a home directory called 'home' in '$tmp/home'
    And a repository 'foo' with versions '1.0.0 1.0.1 1.0.2'

  Scenario: Install with lockfile
    Given flavorfile
      """ruby
      flavor '$foo_uri'
      """
    And lockfile
      """
      $foo_uri (1.0.0)
      """
    When I run `vim-flavor install`
    Then I get lockfile
      """
      $foo_uri (1.0.0)
      """
    And I get a bootstrap script in '$home/.vim'
    And I get flavor '$foo_uri' with '1.0.0' in '$home/.vim'
