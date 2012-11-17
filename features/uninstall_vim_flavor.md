## Uninstallation steps

    rm -r ~/.vim-flavor
    rm -r ~/.vim/flavors  # or ~/vimfiles/flavors etc.

    cd $YOUR_REPOSITORY_FOR_DOTFILES
    rm VimFlavor VimFlavor.lock
    vim vimrc  # Remove the "runtime flavors/bootstrap.vim" line.
    git commit -am 'Farewell to vim-flavor'

    gem uninstall vim-flavor




<!-- vim: set expandtab shiftwidth=4 softtabstop=4 textwidth=78 : -->
