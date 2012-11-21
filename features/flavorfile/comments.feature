Feature: Comments
  In order to remind notable points,
  as a lazy Vim user,
  I want to leave comments in my flavorfile.

  Background:
    Given a temporary directory called 'tmp'
    And a home directory called 'home' in '$tmp/home'
    And a repository 'foo' with versions '1.0 1.1 1.2 2.0'

  Scenario: Comment out declarations
    Given flavorfile
      """ruby
      # Since flavorfile is parsed as a Ruby script,
      # you can comment out arbitrary lines like this.

      # flavor '$foo_uri', '~> 1.0'
      """
    When I run `vim-flavor install`
    Then I get lockfile
      """
      """
    And I get a bootstrap script in '$home/.vim'
    But I don't have flavor '$foo_uri' in '$home/.vim'
