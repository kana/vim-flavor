Feature: `version` command
  In order to know the current version of `vim-flavor`,
  as a lazy Vim user,
  I want to show it from command-line.

  Scenario: Show the current version
    When I run `vim-flavor version`
    Then it should pass with template:
      """
      $version
      """
