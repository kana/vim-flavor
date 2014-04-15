# vim-flavor, a tool to manage your favorite Vim plugins

[![Build Status](https://travis-ci.org/kana/vim-flavor.png)](https://travis-ci.org/kana/vim-flavor)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/kana/vim-flavor)




## Getting started

    cd $YOUR_REPOSITORY_FOR_DOTFILES

    cat >VimFlavor <<'END'
      # * Declare using git://github.com/kana/vim-textobj-indent.git
      # * vim-flavor fetches git://github.com/$USER/$REPO.git
      #   if the argument is written in '$USER/$REPO' format.
      # * kana/vim-textobj-indent requires kana/vim-textobj-user.
      #   Such dependencies are automatically installed
      #   if the flavored plugin declares its dependencies with VimFlavor file.
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

See also
[the documentation on relish](https://www.relishapp.com/kana/vim-flavor) or
`features/` directory for the details.




## License

vim-flavor is released under the terms of MIT license.
See the LICENSE file for the details.




## Author

* [Kana Natsuno](http://whileimautomaton.net/)
  (also known as [@kana1](http://twitter.com/kana1))




<!-- vim: set expandtab shiftwidth=4 softtabstop=4 textwidth=78 : -->
