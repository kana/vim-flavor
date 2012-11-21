@typical_usage
Feature: Install Vim plugins
  In order to automate boring steps,
  as a lazy Vim user,
  I want to use a declarative way to start using new Vim plugins.

  Background:
    Given a temporary directory called 'tmp'
    And a home directory called 'home' in '$tmp/home'
    And a repository 'foo' with versions '1.0.0 1.0.1 1.0.2'

  Scenario: Install from scratch
    Given flavorfile
      """ruby
      """
    When I edit flavorfile as
      """ruby
      flavor '$foo_uri'
      """
    And I run `vim-flavor install`
    Then I get lockfile
      """
      $foo_uri (1.0.2)
      """
    And I get a bootstrap script in '$home/.vim'
    And I get flavor '$foo_uri' with '1.0.2' in '$home/.vim'
