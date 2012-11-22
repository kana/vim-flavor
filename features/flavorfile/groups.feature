Feature: Groups
  In order to deploy a specific set of Vim plugins,
  as a lazy Vim user,
  I want to declare groups of flavors.

  Background:
    Given a temporary directory called 'tmp'
    And a home directory called 'home' in '$tmp/home'
    And a repository 'foo' with versions '1.0 1.1 1.2'
    And a repository 'bar' with versions '2.0 2.1 2.2'
    And a repository 'baz' with versions '3.0 3.1 3.2'
    And a repository 'qux' with versions '4.0 4.1 4.2'
    And flavorfile
      """ruby
      flavor '$foo_uri'
      flavor '$bar_uri', :group => :default
      flavor '$baz_uri', :group => :development
      group :experimental do
        flavor '$qux_uri'
      end
      """

  Scenario: Install flavors without specifying groups
    When I run `vim-flavor install`
    Then I get lockfile
      """
      $bar_uri (2.2)
      $baz_uri (3.2)
      $foo_uri (1.2)
      $qux_uri (4.2)
      """
    And I get a bootstrap script in '$home/.vim'
    And I get flavor '$foo_uri' with '1.2' in '$home/.vim'
    And I get flavor '$bar_uri' with '2.2' in '$home/.vim'
    And I get flavor '$baz_uri' with '3.2' in '$home/.vim'
    And I get flavor '$qux_uri' with '4.2' in '$home/.vim'

  Scenario: Install flavors in specific groups
    When I run `vim-flavor install --with=development,experimental`
    Then I get lockfile
      """
      $bar_uri (2.2)
      $baz_uri (3.2)
      $foo_uri (1.2)
      $qux_uri (4.2)
      """
    And I get a bootstrap script in '$home/.vim'
    But I don't have flavor '$foo_uri' in '$home/.vim'
    But I don't have flavor '$bar_uri' in '$home/.vim'
    And I get flavor '$baz_uri' with '3.2' in '$home/.vim'
    And I get flavor '$qux_uri' with '4.2' in '$home/.vim'

  Scenario: Install flavors not in specific groups
    When I run `vim-flavor install --without=development,experimental`
    Then I get lockfile
      """
      $bar_uri (2.2)
      $baz_uri (3.2)
      $foo_uri (1.2)
      $qux_uri (4.2)
      """
    And I get a bootstrap script in '$home/.vim'
    And I get flavor '$foo_uri' with '1.2' in '$home/.vim'
    And I get flavor '$bar_uri' with '2.2' in '$home/.vim'
    But I don't have flavor '$baz_uri' in '$home/.vim'
    But I don't have flavor '$qux_uri' in '$home/.vim'

  Scenario: `--with` and `--without` are exclusive
    When I run `vim-flavor install --with=heaven --without=hell` but
    Then it fails with messages like
      """
      --with and --without are exclusive.
      """

  Scenario: The default group
    When I run `vim-flavor install --with=default`
    Then I get lockfile
      """
      $bar_uri (2.2)
      $baz_uri (3.2)
      $foo_uri (1.2)
      $qux_uri (4.2)
      """
    And I get a bootstrap script in '$home/.vim'
    And I get flavor '$foo_uri' with '1.2' in '$home/.vim'
    And I get flavor '$bar_uri' with '2.2' in '$home/.vim'
    But I don't have flavor '$baz_uri' in '$home/.vim'
    But I don't have flavor '$qux_uri' in '$home/.vim'
