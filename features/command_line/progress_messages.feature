Feature: Progress messages
  In order to know what is going on,
  as a lazy Vim user,
  I want to see messages about the current progress.

  Scenario: Install Vim plugins successfully
    Given a repository "foo" with versions "1.0.0 1.0.1 1.0.2"
    And a repository "bar" with versions "2.0.0 2.0.1 2.0.2"
    And a flavorfile with:
      """ruby
      flavor '$foo_uri', '~> 1.0'
      flavor '$bar_uri'
      """
    When I run `vim-flavor install`
    Then it should pass with template:
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
    Given a flavorfile with:
      """ruby
      flavor 'file://$tmp/no-such-plugin'
      """
    When I run `vim-flavor install`
    Then it should fail with template:
      """
      Checking versions...
        Use file://$tmp/no-such-plugin ... failed
      """
    And it should fail with regexp:
      """
      fatal: '\S+' does not appear to be a git repository
      """
