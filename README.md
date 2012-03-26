# vim-flavor, a tool to manage your favorite Vim plugins




## Set up the tool for a new-style plugin management

### Requirements

* [Git](http://git-scm.com/) 1.7.9 or later
* [Ruby](http://www.ruby-lang.org/) 1.9.2 or later
  * Recommendation: Use [RVM](http://beginrescueend.com/) or other tools
    for ease of installation across different envinronments.
* [Vim](http://www.vim.org/) 7.3 or later
  * Note that Vim should be compiled as normal, big or huge version
    to use most of plugins.


### Supported platforms

* Unix-like environments such as Linux, Mac OS X, etc.
* Though Microsoft Windows is not directly supported,
  it is possible to manage Vim plugins via Cygwin or other environments.


### Installation steps

    gem install vim-flavor




## Typical usage

### Start using vim-flavor

    cd $YOUR_REPOSITORY_FOR_DOTFILES

    cat >VimFlavor <<'END'
      # * Declare using git://github.com/kana/vim-textobj-indent.git
      # * vim-flavor fetches git://github.com/$USER/$REPO.git
      #   if the argument is written in '$USER/$REPO' format.
      # * kana/vim-textobj-indent requires kana/vim-textobj-user.
      #   Such dependencies are automatically installed
      #   if the flavored plugin declares its dependencies with VimFlavor file.
      #   (FIXME: Resolving dependencies will be implemented later.)
      flavor 'kana/vim-textobj-indent'

      # * Declare using git://github.com/vim-scripts/fakeclip.git
      # * vim-flavor fetches git://github.com/vim-scripts/$REPO.git
      #   if the argument is written in '$REPO' format.
      flavor 'fakeclip'

      # * Declare using git://github.com/kana/vim-altr.git
      # * vim-flavor fetches the URI
      #   if the argument seems to be a URI.
      flavor 'git://github.com/kana/vim-altr.git'

      # * Declare using kana/vim-smartchr 0.1.0 or later and older than 0.2.0.
      flavor 'kana/vim-smartchr', '~> 0.1.0'

      # * Declare using kana/vim-smartword 0.1 or later and older than 1.0.
      flavor 'kana/vim-smartword', '~> 0.1'

      # * Declare using kana/vim-smarttill 0.1.0 or later.
      flavor 'kana/vim-smarttill', '>= 0.1.0'
    END

    # Fetch the plugins declared in the VimFlavor,
    # create VimFlavor.lock for a snapshot of all plugins and versions,
    # then install the plugins and a bootstrap script into ~/.vim etc.
    vim-flavor install

    # Add the following line into the first line of your vimrc:
    #
    #   runtime flavors/bootstrap.vim
    vim vimrc

    git add VimFlavor VimFlavor.lock vimrc
    git commit -m 'Use vim-flavor to manage my favorite Vim plugins'


### Upgrade all plugins to the latest version

    vim-flavor upgrade

    git add VimFlavor.lock
    git commit -m 'Upgrade my favorite Vim plugins'


### Add more plugins into your dotfile repository

    cat >>VimFlavor <<'END'

      flavor 'kana/vim-operator-replace'

    END

    # Fetch newly added plugins,
    # update VimFlavor.lock for the plugins,
    # then install the plugins into ~/.vim etc.
    vim-flavor install

    git add VimFlavor VimFlavor.lock
    git commit -m 'Use kana/vim-operator-replace'


### Remove plugins from your dotfile repository

    # Remove declarations of unused plugins from VimFlavor.
    sed -i~ -e '/vim-smartchr/d' VimFlavor

    # Update VimFlavor.lock for the removed plugins,
    # then clean up the plugins from ~/.vim etc.
    vim-flavor install

    git add VimFlavor VimFlavor.lock
    git commit -m 'Farewell kana/vim-smartchr'



### Install plugins into a non-standard directory

    vim-flavor install --vimfiles-path=/cygdrive/c/Users/kana/vimfiles


### Farewell to vim-flavor

    rm -r ~/.vim-flavor
    rm -r ~/.vim/flavors  # or ~/vimfiles/flavors etc.

    cd $YOUR_REPOSITORY_FOR_DOTFILES
    rm VimFlavor VimFlavor.lock
    git commit -am 'Farewell to vim-flavor'




## Philosophy

I know that there are several implementations for the same purpose and many
users love them, but all of them do not meet my taste.  That's why I wrote
vim-flavor.  The philosofy on vim-flavor is as follows:

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
automatically (unfortunately this feature is not implemented yet, but it'll be
available soon).

Any software should have enough and reproducable test cases.
But existing implementations such as
[vundle](https://github.com/gmarik/vundle) and
[neobundle](https://github.com/Shougo/neobundle.vim) are not developed so.
It's horrible for me.

Installation steps should be small, be reproducable, and not affect existing
envinronment as less as possible.  Most of existing implementations require to
manually tweak `~/.vim` etc.  It's painful to set up such stuffs manually
because a vimfiles path is varied on each platform.

Finally, a tool and files deployed by the tool should be uninstalled easily.
[Vimana](https://github.com/c9s/Vimana) does not meet this because it directly
puts files into `~/.vim/colors` etc and it doesn't provide `uninstall`
command.




## License

vim-flavor is released under the terms of so-called MIT/X license.
See the LICENSE file for the details.




## Author

* [Kana Natsuno](http://whileimautomaton.net/)
  (also known as [@kana1](http://twitter.com/kana1))




<!-- vim: set expandtab shiftwidth=4 softtabstop=4 textwidth=78 : -->
