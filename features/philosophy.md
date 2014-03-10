## Installable plugins

Basically, not all Vim plugins can be installed with vim-flavor.
vim-flavor can install plugins which meet the following conditions:

* Plugins must have dedicated Git repositories.
  vim-flavor does not support other version control systems.
  This is an intentional design.  Because:
  * [vim-scripts.org](http://vim-scripts.org/) provides
    [comprehensive Git mirrors](https://github.com/vim-scripts) for
    [plugins uploaded to www.vim.org](http://www.vim.org/scripts/index.php).
  * Experimental plugins which are not uploaded to www.vim.org
    are usually found in [GitHub](https://github.com/).
* Plugins must follow [the versioning policies of
  RubyGems](http://docs.rubygems.org/read/chapter/7#page26) and have "version"
  tags in their repositories.  For example, if there is the version 1.2.3 of
  a plugin, its repository must have the tag `1.2.3`, and the files of the
  version 1.2.3 can be checked out via the tag `1.2.3`.  In other words,
  plugins which do not have proper tags are not installable.
  This is an intentional design.  Because:
  * It's not possible to determine whether two versions are compatible or not
    without "version" tags.  Compatibility is a big problem to resolve
    dependencies of plugins.  For example, if plugin A requires plugin X 1.2.3
    or later while plugin B requires plugin X 2.0 or later, it's not possible
    to use A and B at the same time.  Such problems should be detected before
    installing plugins.
  * Git mirrors by vim-scripts.org are tagged with version numbers.
  * Some Git repositories might not have "version" tags.
    Such plugins are not ready to use for everyone.
    So that it should not be installable.
* Plugins must have proper directory structures.
  For example, directories such as `autoload`, `syntax` etc should exist in
  the roots of plugins.
  This is an intentional design.  Because:
  * Git mirrors by vim-scripts.org have proper directory structures even if
    the original plugins are uploaded to www.vim.org without proper directory
    structures.  (A good example is
    [a.vim](http://www.vim.org/scripts/script.php?script_id=31) and
    [its mirror](https://github.com/vim-scripts/a.vim).)
  * Other Git repositories might not have proper directory structures.
    Such plugins are not ready to use for everyone.
    So that it should not be installable.

Though the above principle is not changed, nowadays (2014)

* www.vim.org becomes less popular as a central repository of Vim plugins.
  Because:
  * It's a tedious task to publish plugins at www.vim.org because there is no
    standard tool to automate the process to publish plugins.
  * As GitHub becomes more popular, many plugin authors seem to choose only
    GitHub to publish plugins because it is easy and fast.
* As a result, vim-scripts.org's mirrors are mostly outdated.  Latest versions
  are not usually found in the mirrors.  So that GitHub repositories rather
  than vim-scripts.org's mirrors are specified in [flavorfile](./flavorfile)
  in most cases.
* But unlike vim-scripts.org's mirrors, "version" tags might not exist in wild
  repositories.
* And sometimes it's necessary to track a brach with proposed changes which
  are not ready to release as a proper version.

So that [branches](./branches) are also supported.  But branches are not
comparable and it's not possible to detect incompatibility before installing
plugins.  It's not recommended for daily use.  Use branches at your own risk.




## Why make another management tool?

I know that there are several implementations for the same purpose and many
users love them, but all of them do not meet my taste.  That's why I wrote
vim-flavor.  The philosophy on vim-flavor is as follows:

Whole configuration including *versions of plugins* should be under a version
control system.  All of existing implementations do not manage versions of
plugins.  This means that *it's not possible to use the same configuration
across multiple environments* (the only one exception is using
[pathogen](https://github.com/tpope/vim-pathogen) with Git submodules,
but you'll find it's painful to manually manage many plugins).

There should be a standard way to describe proper dependencies of plugins to
install dependencies without explicit declarations.  Most of existing
implementations do not resolve dependencies automatically (the only one
exception is
[vim-addon-manager](https://github.com/MarcWeber/vim-addon-manager), but it
doesn't take care about required versions).  The configuration file formats of
vim-flavor are also used to describe dependencies of plugins with required
versions.  This means that vim-flavor installs plugins and their dependencies
automatically.

Any software should have enough and reproducible test cases.
But existing implementations such as
[vundle](https://github.com/gmarik/vundle) and
[neobundle](https://github.com/Shougo/neobundle.vim) are not developed so.
It's horrible for me.

Installation steps should be small, be reproducible, and not affect existing
environment as less as possible.  Most of existing implementations require to
manually tweak `~/.vim` etc.  It's painful to set up such stuffs manually
because a vimfiles path is varied on each platform.

Finally, a tool and files deployed by the tool should be uninstalled easily.
[Vimana](https://github.com/c9s/Vimana) does not meet this because it directly
puts files into `~/.vim/colors` etc and it doesn't provide `uninstall`
command.




<!-- vim: set expandtab shiftwidth=4 softtabstop=4 textwidth=78 : -->
