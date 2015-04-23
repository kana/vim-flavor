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
