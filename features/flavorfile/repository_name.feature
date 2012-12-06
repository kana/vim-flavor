Feature: Repository name
  In order to keep flavorfile terse and readable,
  as a lazy Vim user,
  I also want to use shorthands for frequently used repositories.

  Scenario: Declare using a Vim plugin from www.vim.org
    Given a GitHub repository "vim-scripts/vspec" with versions "0.0.4 1.2.0"
    And a flavorfile with:
      """ruby
      # Fetch the plugin from git://github.com/vim-scripts/vspec.git
      flavor 'vspec', '~> 0.0'
      """
    When I run `vim-flavor install`
    Then it should pass
    And a lockfile is created with:
      """
      vspec (0.0.4)
      """
    And a bootstrap script is created in "$home/.vim"
    And a flavor "vspec" version "0.0.4" is deployed to "$home/.vim"

  Scenario: Declare using a Vim plugin from GitHub
    Given a GitHub repository "kana/vim-vspec" with versions "0.0.4 1.2.0"
    And a flavorfile with:
      """ruby
      # Fetch the plugin from git://github.com/kana/vim-vspec.git
      flavor 'kana/vim-vspec', '~> 0.0'
      """
    When I run `vim-flavor install`
    Then it should pass
    And a lockfile is created with:
      """
      kana/vim-vspec (0.0.4)
      """
    And a bootstrap script is created in "$home/.vim"
    And a flavor "kana/vim-vspec" version "0.0.4" is deployed to "$home/.vim"

  Scenario: Declare using a Vim plugin from an arbitrary URI
    Given a local repository "vspec" with versions "0.0.4 1.2.0"
    And a flavorfile with:
      """ruby
      # Fetch the plugin from the URI.
      flavor '$vspec_uri', '~> 0.0'
      """
    When I run `vim-flavor install`
    Then it should pass
    And a lockfile is created with:
      """
      $vspec_uri (0.0.4)
      """
    And a bootstrap script is created in "$home/.vim"
    And a flavor "$vspec_uri" version "0.0.4" is deployed to "$home/.vim"
