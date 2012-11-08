Feature: Upgrade Vim plugins
  As a lazy Vim user
  I want to upgrade Vim plugins
  without pain

  Background:
    Given a temporary directory called 'tmp'
    And a home directory called 'home' in '$tmp/home'
    And a repository 'foo' with versions '1.0.0 1.0.1 1.0.2'

  Scenario: Upgrade with lockfile
    Given flavorfile
      """
      flavor '$foo_uri'
      """
    And lockfile
      """
      $foo_uri (1.0.0)
      """
    When I run vim-flavor with 'upgrade'
    Then I get lockfile
      """
      $foo_uri (1.0.2)
      """
    And I get a bootstrap script in '$home'
    And I get flavor 'foo' with '1.0.2' in '$home'
