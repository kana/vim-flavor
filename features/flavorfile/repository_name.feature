Feature: Repository name
  In order to keep flavorfile terse and readable,
  as a lazy Vim user,
  I also want to use shorthands for frequently used repositories.

  Background:
    Given a temporary directory called 'tmp'
    And a home directory called 'home' in '$tmp/home'

  Scenario: Declare using a Vim plugin from www.vim.org
    Given a repository 'vim-scripts/vspec' with versions '0.0.4 1.2.0'
    And flavorfile
      """ruby
      # Fetch the plugin from git://github.com/vim-scripts/vspec.git
      flavor 'vspec', '~> 0.0'
      """
    When I run `vim-flavor install`
    Then I get lockfile
      """
      vspec (0.0.4)
      """
    And I get a bootstrap script in '$home/.vim'
    And I get flavor 'vspec' with '0.0.4' in '$home/.vim'

  Scenario: Declare using a Vim plugin from GitHub
    Given a repository 'kana/vim-vspec' with versions '0.0.4 1.2.0'
    And flavorfile
      """ruby
      # Fetch the plugin from git://github.com/kana/vim-vspec.git
      flavor 'kana/vim-vspec', '~> 0.0'
      """
    When I run `vim-flavor install`
    Then I get lockfile
      """
      kana/vim-vspec (0.0.4)
      """
    And I get a bootstrap script in '$home/.vim'
    And I get flavor 'kana/vim-vspec' with '0.0.4' in '$home/.vim'

  Scenario: Declare using a Vim plugin from an arbitrary URI
    Given a repository 'vspec' with versions '0.0.4 1.2.0'
    And flavorfile
      """ruby
      # Fetch the plugin from the URI.
      flavor '$vspec_uri', '~> 0.0'
      """
    When I run `vim-flavor install`
    Then I get lockfile
      """
      $vspec_uri (0.0.4)
      """
    And I get a bootstrap script in '$home/.vim'
    And I get flavor '$vspec_uri' with '0.0.4' in '$home/.vim'
