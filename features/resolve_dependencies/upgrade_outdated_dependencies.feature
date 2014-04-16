Feature: Update outdated dependencies of Vim plugins
  In order to smoothly install Vim plugins,
  as a lazy Vim user,
  I want to automatically update outdated dependencies of Vim plugins.

  Scenario: Some plugins use outdated dependencies
    Given a repository "L" with versions "0.1 0.2 0.3 0.4"
    And a repository "A" with versions "0.0" and a flavorfile:
      """ruby
      flavor '$L_uri', '~> 0.3'
      """
    And a repository "B" with versions "0.0" and a flavorfile:
      """ruby
      flavor '$L_uri', '~> 0.3'
      """
    And a flavorfile with:
      """ruby
      flavor '$A_uri'
      flavor '$B_uri'
      flavor '$L_uri'
      """
    And I run `vim-flavor install`
    And it should pass with template:
      """
      Checking versions...
        Use $A_uri ... 0.0
          Use $L_uri ... 0.4
        Use $B_uri ... 0.0
          Use $L_uri ... 0.4
        Use $L_uri ... 0.4
      Deploying plugins...
        $A_uri 0.0 ... done
        $B_uri 0.0 ... done
        $L_uri 0.4 ... done
      Completed.
      """
    And a lockfile is created with:
      """
      $A_uri (0.0)
      $B_uri (0.0)
      $L_uri (0.4)
      """
    And a bootstrap script is created in "$home/.vim"
    And a flavor "$A_uri" version "0.0" is deployed to "$home/.vim"
    And a flavor "$B_uri" version "0.0" is deployed to "$home/.vim"
    And a flavor "$L_uri" version "0.4" is deployed to "$home/.vim"
    When "L" version "0.5" is released
    And a repository "X" with versions "0.0" and a flavorfile:
      """ruby
      flavor '$L_uri', '~> 0.5'
      """
    And I edit the flavorfile as:
      """ruby
      flavor '$A_uri'
      flavor '$B_uri'
      flavor '$L_uri'
      flavor '$X_uri'
      """
    And I run `vim-flavor install`
    Then it should pass with template:
      """
      Checking versions...
        Use $A_uri ... 0.0
          Use $L_uri ... 0.4
        Use $B_uri ... 0.0
          Use $L_uri ... 0.4
        Use $L_uri ... 0.4
        Use $X_uri ... 0.0
          Use $L_uri ... 0.5
      Deploying plugins...
        $A_uri 0.0 ... skipped (already deployed)
        $B_uri 0.0 ... skipped (already deployed)
        $L_uri 0.5 ... done
        $X_uri 0.0 ... done
      Completed.
      """
    And a lockfile is created with:
      """
      $A_uri (0.0)
      $B_uri (0.0)
      $L_uri (0.5)
      $X_uri (0.0)
      """
    And a bootstrap script is created in "$home/.vim"
    And a flavor "$A_uri" version "0.0" is deployed to "$home/.vim"
    And a flavor "$B_uri" version "0.0" is deployed to "$home/.vim"
    And a flavor "$L_uri" version "0.5" is deployed to "$home/.vim"
    And a flavor "$X_uri" version "0.0" is deployed to "$home/.vim"
