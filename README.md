# vim-flavor, a tool to manage your favorite Vim plugins

[![CI](https://github.com/kana/vim-flavor/actions/workflows/ci.yml/badge.svg)](https://github.com/kana/vim-flavor/actions/workflows/ci.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/97414d95fb6d19c7fb72/maintainability)](https://codeclimate.com/github/kana/vim-flavor/maintainability)




# Getting started

## Create `Flavorfile`

This file contains a set of declarations about what Vim plugins you want to
install.  For example:

```ruby
# Install a Vim plugin from `https://github.com/kana/vim-textobj-indent`.
#
# Note that kana/vim-textobj-indent requires kana/vim-textobj-user.
# Such dependencies are automatically installed if the former plugin
# declares its dependencies with Flavorfile.
flavor 'kana/vim-textobj-indent'

# Install a Vim plugin from `https://github.com/vim-scripts/fakeclip`.
flavor 'fakeclip'

# Install a Vim plugin from the specified URI.
flavor 'git://github.com/kana/vim-altr.git'

# You can also specify which version of Vim plugin should be installed.
# For example:
flavor 'kana/vim-smartword', '~> 0.1'    # 0.1 or later, but older than 0.2
flavor 'kana/vim-smartchr',  '~> 0.2.4'  # 0.2.4 or later, but older than 0.3.0
flavor 'kana/vim-smarttill', '>= 0.3.6'  # 0.3.6 or later

# vim-flavor, by design, requires Vim plugins to follow semantic versioning
# and to create version tags (like `v1.2.3`) in their repositories.
#
# For repositories without versioning, branches can be specified.
flavor 'chriskempson/base16-vim', branch: 'master'
```

## Install Vim plugins (for the first time)

Run the following command:

```bash
vim-flavor install
```

This command does the following stuffs:

1. Fetches Vim plugins declared in the `Flavorfile`.
2. Creates `Flavorfile.lock` file.  It contains information about what
   versions of plugins to be installed.
3. Copies the fetched plugins into `~/.vim/pack/flavors/start`, then updates
   help tags for each plugin.

It's recommended to commit `Flavorfile` and `Flavorfile.lock` after
installation.

```bash
git add Flavorfile Flavorfile.lock
git commit -m 'Use vim-flavor to manage my favorite Vim plugins'
```

## Install Vim plugins (from another machine)

Suppose that you work with several PCs and/or servers, and you want to use the
same configuration, including Vim plugins, on all of them.

Firstly, let's synchronize your configuration files:

```bash
cd ~/your/dotfiles/repository
git pull
```

Now you have the same `Flavorfile` and `Flavorfile.lock` created by the
previous step.

Then run the following command:

```bash
vim-flavor install
```

This time `vim-flavor` installs the same versions of Vim plugins as recorded
in `Flavorfile.lock`, even if newer versions are available.

## Update Vim plugins

To update Vim plugins, run the following command:

```bash
vim-flavor update
```

This is similar to `vim-flavor install`, but vim-flavor tries checking and
installing newer versions of Vim plugins.

This command usually updates `Flavorfile.lock`.  So that you have to commit it
again.

```bash
git add Flavorfile.lock
git commit -m 'Update Vim plugins'
```




# References

See [`features/`](./features) directory for the details.
The same [documents](https://www.relishapp.com/kana/vim-flavor) are available
also on relish.




# License

vim-flavor is released under the terms of MIT license.
See the [LICENSE](./LICENSE) file for the details.




# Development

## Set up

1. Install [rbenv](https://github.com/rbenv/rbenv).
2. Run the following commands in your clone of vim-flavor repository:

   ```bash
   git submodule update --init
   rbenv install
   bundle install
   ```

## Run tests

```bash
rake test
```




# Author

* [kana](https://github.com/kana)




<!-- vim: set expandtab shiftwidth=4 softtabstop=4 textwidth=78 : -->
