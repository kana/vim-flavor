Feature: Install Vim plugins
  As a lazy Vim user
  I want to install Vim plugins
  without pain

  Background:
    Given a temporary directory called 'tmp'
    And a home directory called 'home' in '$tmp/home'
    And a repository 'foo' with versions '1.0.0 1.0.1 1.0.2'

  Scenario: Install from scratch
    Given flavorfile
      """
      flavor '$foo_uri'
      """
    When I run vim-flavor with 'install'
    Then I get lockfile
      """
      $foo_uri (1.0.2)
      """
    And I get a bootstrap script in '$home'
    And I get flavor 'foo' with '1.0.2' in '$home'

  Scenario: Install with lockfile
    Given flavorfile
      """
      flavor '$foo_uri'
      """
    And lockfile
      """
      $foo_uri (1.0.0)
      """
    When I run vim-flavor with 'install'
    Then I get lockfile
      """
      $foo_uri (1.0.0)
      """
    And I get a bootstrap script in '$home'
    And I get flavor 'foo' with '1.0.0' in '$home'

  @wip
  Scenario: Install to specified path
    Given flavorfile
      """
      flavor '$foo_uri'
      """
    When I run vim-flavor with 'install --vimfiles-path=$tmp'
    Then I get lockfile
      """
      $foo_uri (1.0.2)
      """
    And I get a bootstrap script in '$tmp'
    And I get flavor 'foo' with '1.0.2' in '$tmp'
