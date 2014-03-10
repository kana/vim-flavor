Feature: Detect incompatible declarations
  In order to avoid using Vim with inconsistent configurations,
  as a lazy Vim user,
  I want to detect incompatible declaratios before installing Vim plugins.

  Scenario: Detect incompatible branches
    Given a repository "L" with versions "0.1 0.2 0.3 0.4"
    And "L" has "experimental" branch
    And a repository "A" with versions "0.0" and a flavorfile:
      """ruby
      flavor '$L_uri', branch: 'master'
      """
    And a repository "B" with versions "0.0" and a flavorfile:
      """ruby
      flavor '$L_uri', branch: 'experimental'
      """
    And a flavorfile with:
      """ruby
      flavor '$A_uri'
      flavor '$B_uri'
      """
    When I run `vim-flavor install`
    Then it should fail with template:
      """
      Checking versions...
        Use $A_uri ... 0.0
          Use $L_uri ... $L_rev_04 at master
        Use $B_uri ... 0.0
          Use $L_uri ... $L_rev_04 at experimental
      Found incompatible declarations:
        $L_uri branch: master is required by $A_uri
        $L_uri branch: experimental is required by $B_uri
      Please resolve the conflict.
      """
    And a bootstrap script is not created in "$home/.vim"
    And a flavor "$A_uri" is not deployed to "$home/.vim"
    And a flavor "$B_uri" is not deployed to "$home/.vim"
    And a flavor "$L_uri" is not deployed to "$home/.vim"

  Scenario: Detect mixed use of branchs and versions
    Given a repository "L" with versions "0.1 0.2 0.3 0.4"
    And "L" has "experimental" branch
    And a repository "A" with versions "0.0" and a flavorfile:
      """ruby
      flavor '$L_uri', branch: 'master'
      """
    And a repository "B" with versions "0.0" and a flavorfile:
      """ruby
      flavor '$L_uri', '~> 0.2'
      """
    And a flavorfile with:
      """ruby
      flavor '$A_uri'
      flavor '$B_uri'
      """
    When I run `vim-flavor install`
    Then it should fail with template:
      """
      Checking versions...
        Use $A_uri ... 0.0
          Use $L_uri ... $L_rev_04 at master
        Use $B_uri ... 0.0
          Use $L_uri ... 0.4
      Found incompatible declarations:
        $L_uri branch: master is required by $A_uri
        $L_uri ~> 0.2 is required by $B_uri
      Please resolve the conflict.
      """
    And a bootstrap script is not created in "$home/.vim"
    And a flavor "$A_uri" is not deployed to "$home/.vim"
    And a flavor "$B_uri" is not deployed to "$home/.vim"
    And a flavor "$L_uri" is not deployed to "$home/.vim"
