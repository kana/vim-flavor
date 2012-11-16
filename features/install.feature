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
    And I get a bootstrap script in '$home/.vim'
    And I get flavor 'foo' with '1.0.2' in '$home/.vim'

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
    And I get a bootstrap script in '$home/.vim'
    And I get flavor 'foo' with '1.0.0' in '$home/.vim'

  Scenario: Install to specified vimfiles path which does not exist
    Given flavorfile
      """
      flavor '$foo_uri'
      """
    And I don't have a directory called '$tmp/my-vimfiles'
    When I run vim-flavor with 'install --vimfiles-path=$tmp/my-vimfiles'
    Then I get lockfile
      """
      $foo_uri (1.0.2)
      """
    And I get a bootstrap script in '$tmp/my-vimfiles'
    And I get flavor 'foo' with '1.0.2' in '$tmp/my-vimfiles'

  @wip
  Scenario: Install after deleting some flavors in flavorfile
    Given a repository 'bar' with versions '2.0.0 2.0.1 2.0.2'
    And flavorfile
      """
      flavor '$foo_uri'
      flavor '$bar_uri'
      """
    When I run vim-flavor with 'install'
    And I edit flavorfile as
      """
      flavor '$bar_uri'
      """
    And I run vim-flavor with 'install' again
    Then I get lockfile
      """
      $bar_uri (2.0.2)
      """
    And I get a bootstrap script in '$home/.vim'
    And I get flavor 'bar' with '2.0.2' in '$home/.vim'
    But I don't have flavor 'foo' in '$home/.vim'
