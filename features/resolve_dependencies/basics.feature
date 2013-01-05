Feature: Resolve dependencies of Vim plugins
  In order to hide details of dependencies,
  as a lazy Vim user,
  I want to resolve and install dependencies of Vim plugins automatically.

  Scenario: Resolve 2-level dependencies
    Given a repository "foo" with versions "1.0 1.1 2.0 2.1"
    And a repository "bar" with versions "1.0 1.1 2.0 2.1"
    And a repository "qux" with versions "1.0 1.1 2.0 2.1" and a flavorfile:
      """ruby
      flavor '$foo_uri', '~> 1.0'
      flavor '$bar_uri', '>= 1.0'
      """
    And a flavorfile with:
      """ruby
      flavor '$qux_uri'
      """
    When I run `vim-flavor install`
    Then it should pass with template:
      """
      Checking versions...
        Use $qux_uri ... 2.1
          Use $bar_uri ... 2.1
          Use $foo_uri ... 1.1
      Deploying plugins...
        $bar_uri 2.1 ... done
        $foo_uri 1.1 ... done
        $qux_uri 2.1 ... done
      Completed.
      """
    And a lockfile is created with:
      """
      $bar_uri (2.1)
      $foo_uri (1.1)
      $qux_uri (2.1)
      """
    And a bootstrap script is created in "$home/.vim"
    And a flavor "$foo_uri" version "1.1" is deployed to "$home/.vim"
    And a flavor "$bar_uri" version "2.1" is deployed to "$home/.vim"
    And a flavor "$qux_uri" version "2.1" is deployed to "$home/.vim"

  Scenario: Resolve 3-level dependencies
    Given a repository "foo" with versions "1.0 1.1 2.0 2.1"
    And a repository "bar" with versions "1.0 1.1 2.0 2.1" and a flavorfile:
      """ruby
      flavor '$foo_uri', '~> 1.0'
      """
    And a repository "qux" with versions "1.0 1.1 2.0 2.1" and a flavorfile:
      """ruby
      flavor '$bar_uri', '~> 2.0'
      """
    And a flavorfile with:
      """ruby
      flavor '$qux_uri', '~> 1.0'
      """
    When I run `vim-flavor install`
    Then it should pass with template:
      """
      Checking versions...
        Use $qux_uri ... 1.1
          Use $bar_uri ... 2.1
            Use $foo_uri ... 1.1
      Deploying plugins...
        $bar_uri 2.1 ... done
        $foo_uri 1.1 ... done
        $qux_uri 1.1 ... done
      Completed.
      """
    And a lockfile is created with:
      """
      $bar_uri (2.1)
      $foo_uri (1.1)
      $qux_uri (1.1)
      """
    And a bootstrap script is created in "$home/.vim"
    And a flavor "$foo_uri" version "1.1" is deployed to "$home/.vim"
    And a flavor "$bar_uri" version "2.1" is deployed to "$home/.vim"
    And a flavor "$qux_uri" version "1.1" is deployed to "$home/.vim"

  Scenario: Resolve dependencies of a plugin required by two or more plugins
    Given a repository "foo" with versions "1.0 1.1 2.0 2.1"
    And a repository "bar" with versions "1.0 1.1 2.0 2.1" and a flavorfile:
      """ruby
      flavor '$foo_uri', '>= 1.0'
      """
    And a repository "qux" with versions "1.0 1.1 2.0 2.1" and a flavorfile:
      """ruby
      flavor '$foo_uri', '~> 2.0'
      """
    And a flavorfile with:
      """ruby
      flavor '$bar_uri'
      flavor '$qux_uri'
      """
    When I run `vim-flavor install`
    Then it should pass with template:
      """
      Checking versions...
        Use $bar_uri ... 2.1
          Use $foo_uri ... 2.1
        Use $qux_uri ... 2.1
          Use $foo_uri ... 2.1
      Deploying plugins...
        $bar_uri 2.1 ... done
        $foo_uri 2.1 ... done
        $qux_uri 2.1 ... done
      Completed.
      """
    And a lockfile is created with:
      """
      $bar_uri (2.1)
      $foo_uri (2.1)
      $qux_uri (2.1)
      """
    And a bootstrap script is created in "$home/.vim"
    And a flavor "$foo_uri" version "2.1" is deployed to "$home/.vim"
    And a flavor "$bar_uri" version "2.1" is deployed to "$home/.vim"
    And a flavor "$qux_uri" version "2.1" is deployed to "$home/.vim"

  Scenario: Resolve dependencies of a plugin required by plugins and user
    Given a repository "foo" with versions "1.0 1.1 2.0 2.1"
    And a repository "bar" with versions "1.0 1.1 2.0 2.1" and a flavorfile:
      """ruby
      flavor '$foo_uri', '>= 1.0'
      """
    And a flavorfile with:
      """ruby
      flavor '$foo_uri'
      flavor '$bar_uri'
      """
    When I run `vim-flavor install`
    Then it should pass with template:
      """
      Checking versions...
        Use $bar_uri ... 2.1
          Use $foo_uri ... 2.1
        Use $foo_uri ... 2.1
      Deploying plugins...
        $bar_uri 2.1 ... done
        $foo_uri 2.1 ... done
      Completed.
      """
    And a lockfile is created with:
      """
      $bar_uri (2.1)
      $foo_uri (2.1)
      """
    And a bootstrap script is created in "$home/.vim"
    And a flavor "$foo_uri" version "2.1" is deployed to "$home/.vim"
    And a flavor "$bar_uri" version "2.1" is deployed to "$home/.vim"
