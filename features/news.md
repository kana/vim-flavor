## vim-flavor 3.0.0

### Enhancements

* Steps to start using vim-flavor are simplified.  Especially, it is not
  necessary to edit vimrc.

### Incompatible changes

* Vim 8.0 or later is required now.
* Deployment format is changed.  It might be necessary to manually delete some
  directories and files.  See also the follwoing migration guide.
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
* Rename `VimFlavor` as `Flavorfile`.
* Rename `VimFlavor.lock` as `Flavorfile.lock`.




## vim-flavor 2.2.2

### Bug Fixes

* Fix `install`, `update` and `test` to work even if these commands are invoked
  from non-bash shell.




## vim-flavor 2.2.1

### Bug Fixes

* Fix not to fail fetching repositories which have non-fastforward updates.




## vim-flavor 2.2.0

### Enhancements

* `test` runs `*.vim` and `*.t` in a single step, to get a simplified result.
* `test` uses [vim-vspec](https://github.com/kana/vim-vspec) 1.5 or later by
  default.
* `test` supports `--update-dependencies` to update dependencies before running
  tests.




## vim-flavor 2.1.1

### Enhancements

* `install` and `update` skip checking versions of plugins which are
  development dependencies.




## vim-flavor 2.1.0

### Enhancements

* `update` command is added.  It is an alias of existing `upgrade` command.
  Now it is recommended to use `update` rather than `upgrade`.
  `upgrade` will be removed in a future version.
* `update` and `upgrade` learned to update specific plugins if repository names
  are given as command-line arguments.




## vim-flavor 2.0.0

### Enhancements

* [Branches](./branches) are supported.


### Incompatible changes

* Ruby 2.0.0 or later is required to run vim-flavor.
