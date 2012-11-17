@typical_usage
Feature: Upgrade Vim plugins
  In order to automate boring steps,
  as a lazy Vim user,
  I want to use a declarative way to upgrade my favorite Vim plugins.

  Background:
    Given a temporary directory called 'tmp'
    And a home directory called 'home' in '$tmp/home'
    And a repository 'foo' with versions '1.0.0 1.0.1 1.0.2'

  Scenario: Upgrade with lockfile
    Given flavorfile
      """ruby
      flavor '$foo_uri'
      """
    And lockfile
      """
      $foo_uri (1.0.0)
      """
    When I run `vim-flavor upgrade`
    Then I get lockfile
      """
      $foo_uri (1.0.2)
      """
    And I get a bootstrap script in '$home/.vim'
    And I get flavor 'foo' with '1.0.2' in '$home/.vim'
