Feature: Comments
  In order to remind notable points,
  as a lazy Vim user,
  I want to leave comments in my flavorfile.

  Background:
    Given a repository "foo" with versions "1.0 1.1 1.2 2.0"

  Scenario: Comment out declarations
    Given a flavorfile with:
      """ruby
      # Since flavorfile is parsed as a Ruby script,
      # you can comment out arbitrary lines like this.

      # flavor '$foo_uri', '~> 1.0'
      """
    When I run `vim-flavor install`
    Then it should pass
    And a lockfile is created with:
      """
      """
    And a bootstrap script is created in "$home/.vim"
    But a flavor "$foo_uri" is not deployed to "$home/.vim"
