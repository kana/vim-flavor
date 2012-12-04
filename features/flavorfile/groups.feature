Feature: Groups
  In order to deploy a specific set of Vim plugins,
  as a lazy Vim user,
  I want to declare groups of flavors.

  Background:
    Given a temporary directory called 'tmp'
    And a home directory called 'home' in '$tmp/home'
    And a repository 'foo' with versions '1.0 1.1 1.2'
    And a repository 'bar' with versions '2.0 2.1 2.2'

  Scenario: Install only runtime dependencies
    Given flavorfile
      """ruby
      flavor '$foo_uri', :group => :runtime
      flavor '$bar_uri', :group => :development
      """
    When I run `vim-flavor install`
    Then I get lockfile
      """
      $bar_uri (2.2)
      $foo_uri (1.2)
      """
    And I get a bootstrap script in '$home/.vim'
    And I get flavor '$foo_uri' with '1.2' in '$home/.vim'
    But I don't have flavor '$bar_uri' in '$home/.vim'

  Scenario: The default group
    Given flavorfile
      """ruby
      flavor '$foo_uri'
      flavor '$bar_uri', :group => :development
      """
    When I run `vim-flavor install`
    Then I get lockfile
      """
      $bar_uri (2.2)
      $foo_uri (1.2)
      """
    And I get a bootstrap script in '$home/.vim'
    And I get flavor '$foo_uri' with '1.2' in '$home/.vim'
    But I don't have flavor '$bar_uri' in '$home/.vim'

  Scenario: Group a bunch of flavors at once
    Given flavorfile
      """ruby
      group :development do
        flavor '$foo_uri'
        flavor '$bar_uri'
      end
      """
    When I run `vim-flavor install`
    Then I get lockfile
      """
      $bar_uri (2.2)
      $foo_uri (1.2)
      """
    And I get a bootstrap script in '$home/.vim'
    But I don't have flavor '$foo_uri' in '$home/.vim'
    But I don't have flavor '$bar_uri' in '$home/.vim'
