@typical_usage
Feature: Delete Vim plugins
  In order to automate boring steps,
  as a lazy Vim user,
  I want to use a declarative way to delete Vim plugins from my configuration.

  Background:
    Given a temporary directory called 'tmp'
    And a home directory called 'home' in '$tmp/home'
    And a repository 'foo' with versions '1.0.0 1.0.1 1.0.2'

  Scenario: Install after deleting some flavors in flavorfile
    Given a repository 'bar' with versions '2.0.0 2.0.1 2.0.2'
    And flavorfile
      """
      flavor '$foo_uri'
      flavor '$bar_uri'
      """
    When I run `vim-flavor install`
    And I edit flavorfile as
      """
      flavor '$bar_uri'
      """
    And I run `vim-flavor install` again
    Then I get lockfile
      """
      $bar_uri (2.0.2)
      """
    And I get a bootstrap script in '$home/.vim'
    And I get flavor 'bar' with '2.0.2' in '$home/.vim'
    But I don't have flavor 'foo' in '$home/.vim'
