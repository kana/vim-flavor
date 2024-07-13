# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).




## [Unreleased](https://github.com/kana/vim-flavor/compare/v4.0.3...master)




## [4.0.3](https://github.com/kana/vim-flavor/compare/v4.0.2...v4.0.3) - 2024-07-13

### Fixed

* Fix an error while installing Vim plugins caused by Vim 9.1.0573 or later.




## [4.0.2](https://github.com/kana/vim-flavor/compare/v4.0.1...v4.0.2) - 2022-01-11

### Fixed

* Remove deprecated usage of `.exists?` style methods ([#66](https://github.com/kana/vim-flavor/pull/66))




## [4.0.1](https://github.com/kana/vim-flavor/compare/v4.0.0...v4.0.1) - 2021-11-02

### Changed

* **BREAKING**: Use `https://github.com/...` instead of `git://github.com/...`
  to clone Vim plugin repositories.  This change is required because
  [GitHub deprecates `git://`](https://github.blog/2021-09-01-improving-git-protocol-security-github/)
  since 2021-11-02.

  This is a breaking change if you installed Vim plugins with vim-flavor v4.0.0
  or older.  You'll see the following error in that case:

      fatal: remote error:
        The unauthenticated git protocol on port 9418 is no longer supported.

  There are two ways to fix this errors:

  (A) Delete local clones:

      rm -rf ~/.vim-flavor

  (B) Change `remote.origin.url` of each local clone:

      for d in ~/.vim-flavor/repos/*/
      do
        cd "$d" &&
          git config remote.origin.url "$(git config remote.origin.url | sed 's!^git://!https://!')"
      done

### Fixed

- Update some tests not to fail with `vX.X.X` style version tags.




## [4.0.0](https://github.com/kana/vim-flavor/compare/v3.0.0...v4.0.0) - 2021-09-22

### Changed

* **BREAKING**: Ruby 3.0 or later is required now.




## [3.0.0](https://github.com/kana/vim-flavor/compare/v2.2.2...v3.0.0) - 2018-03-24

### Improved

* Steps to start using vim-flavor are simplified.  Especially, it is not
  necessary to edit vimrc.

### Changed

* **BREAKING**: Vim 8.0 or later is required now.
* **BREAKING**: Deployment format is changed.  It might be necessary to
  manually delete some directories and files.  See also the follwoing migration
  guide.
* The name of configuration file is changed.
  * Old name is `VimFlavor`.
  * New name is `Flavorfile`.
  * Note that old name is still supported for backward compatibility.  Old
    name file is used if there is no new name file.  But it is highly
    recommended to rename.
* The name of lock file is changed.
  * Old name is `VimFlavor.lock`.
  * New name is `Flavorfile.lock`.
  * To avoid unexpected result and confusion, vim-flavor stops its process as
    soon as possible if old name lockfile exists.

### Migration guide from version 2

* Delete `~/.vim/flavors` directory.
* Delete `runtime flavors/bootstrap.vim` line from your vimrc.
* In your dotfiles repository:
  * Rename `VimFlavor` as `Flavorfile`.
  * Rename `VimFlavor.lock` as `Flavorfile.lock`.
* If you use vim-flavor for Vim plugin development, do the following steps in
  that Vim plugin repository:
  * Update `Gemfile` to uses vim-flavor 3.0 or later,
    e.g., `gem 'vim-flavor', '~> 3.0'`.
  * Rename `VimFlavor` as `Flavorfile`.
  * Delete `.vim-flavor` directory.  It is used to stash runtime dependencies to
    run tests for your Vim plugin.
  * Note that you must not commit `Flavorfile.lock` for your Vim plugin.  It
    makes your plugin hard to use with other plugins.




## [2.2.2](https://github.com/kana/vim-flavor/compare/v2.2.1...v2.2.2) - 2018-01-31

### Fixed

* Fixed `install`, `update` and `test` to work even if these commands are
  invoked from non-bash shell.




## [2.2.1](https://github.com/kana/vim-flavor/compare/v2.2.0...v2.2.1) - 2015-04-24

### Fixed

* Fixed not to fail fetching repositories which have non-fastforward updates.




## [2.2.0](https://github.com/kana/vim-flavor/compare/v2.1.1...v2.2.0) - 2015-04-18

### Improved

* `test` runs `*.vim` and `*.t` in a single step, to get a simplified result.
* `test` uses [vim-vspec](https://github.com/kana/vim-vspec) 1.5 or later by
  default.
* `test` supports `--update-dependencies` to update dependencies before running
  tests.




## [2.1.1](https://github.com/kana/vim-flavor/compare/2.1.0...v2.1.1) - 2015-02-25

### Improved

* `install` and `update` skip checking versions of plugins which are
  development dependencies.




## [2.1.0](https://github.com/kana/vim-flavor/compare/2.0.0...2.1.0) - 2014-04-19

### Improved

* `update` command is added.  It is an alias of existing `upgrade` command.
  Now it is recommended to use `update` rather than `upgrade`.
  `upgrade` will be removed in a future version.
* `update` and `upgrade` learned to update specific plugins if repository names
  are given as command-line arguments.




## [2.0.0](https://github.com/kana/vim-flavor/compare/1.1.5...2.0.0) - 2014-03-10

### Improved

* [Branches](./branches) are supported.

### Changed

* **BREAKING**: Ruby 2.0.0 or later is required now.
