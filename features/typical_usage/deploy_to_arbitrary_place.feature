@typical_usage
Feature: Deploy Vim plugins to a non-standard directory
  In order to provide flexibility,
  as a lazy Vim user,
  I want to deploy Vim plugins to arbitrary place.

  Background:
    Given a temporary directory called 'tmp'
    And a home directory called 'home' in '$tmp/home'
    And a repository 'foo' with versions '1.0.0 1.0.1 1.0.2'

  Scenario: Install to specified vimfiles path which does not exist
    Given flavorfile
      """
      flavor '$foo_uri'
      """
    And I don't have a directory called '$tmp/my-vimfiles'
    When I run `vim-flavor install --vimfiles-path=$tmp/my-vimfiles`
    Then I get lockfile
      """
      $foo_uri (1.0.2)
      """
    And I get a bootstrap script in '$tmp/my-vimfiles'
    And I get flavor 'foo' with '1.0.2' in '$tmp/my-vimfiles'
