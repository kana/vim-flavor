Feature: Progress messages
  In order to know what is going on,
  as a lazy Vim user,
  I want to see messages about the current progress.

  Background:
    Given a temporary directory called 'tmp'
    And a home directory called 'home' in '$tmp/home'

  Scenario: Install Vim plugins successfully
    Given a repository 'foo' with versions '1.0.0 1.0.1 1.0.2'
    And a repository 'bar' with versions '2.0.0 2.0.1 2.0.2'
    And flavorfile
      """ruby
      flavor '$foo_uri', '~> 1.0'
      flavor '$bar_uri'
      """
    When I run `vim-flavor install`
    Then it outputs progress like
      """
      Checking versions...
        Use $bar_uri ... 2.0.2
        Use $foo_uri ... 1.0.2
      Deploying plugins...
        $bar_uri 2.0.2 ... done
        $foo_uri 1.0.2 ... done
      Completed.
      """

  Scenario: Install Vim plugins which are not existing
    Given flavorfile
      """ruby
      flavor 'no-such-plugin'
      """
    When I run `vim-flavor install` but
    Then it fails with messages like
      """
      fatal: '\S+' does not appear to be a git repository
      """
    And it outputs progress like
      """
      Checking versions...
        Use no-such-plugin ... failed
      """
