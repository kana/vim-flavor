## Abstract

As a skilled Vim user, it is an exciting time to start using a new plugin,
but installation is not so, because there are several steps to do like the
following:

1. Get a package of the plugin.
2. Copy source tree in the package into `~/.vim` etc.
3. Generate the help tags file for the plugin.

It is also exciting to update favorite Vim plugins to the latest version,
but I don't want to repeat the steps for each plugin.  It's boring.

Some plugins depend on other plugins, so that I have to install also
dependencies, but it is easy to forget about dependencies.
It's sad to see error messages like "E117: Unknown function: foo#bar".

It would be better to automate these routine works with a declarative way,
and `vim-flavor` does it.




## Typical workflow

    cd $YOUR_REPOSITORY_FOR_DOTFILES

    # Add, delete or change declarations which versions of Vim plugins to use.
    vim VimFlavor

    # Install Vim plugins according to VimFlavor.
    vim-flavor install

    # Record changes to the declarations and locked status.
    git add VimFlavor VimFlavor.lock
    git commit -m '...'




## Flavorfile (`VimFlavor`)

`vim-flavor` reads a file `VimFlavor` in the current working directory.
The file is called a flavorfile.  A flavorfile contains zero or more
declarations about Vim plugins and which versions of Vim plugins to use.

See also [more details about flavorfile](flavorfile).




## Lockfile (`VimFlavor.lock`)

`vim-flavor` creates a file `VimFlavor.lock` in the current working directory.
The file is called a lockfile.  A lockfile contains details about installed
Vim plugins to use the same configuration on every machine.

You don't have to care about the content of a lockfile.




<!-- vim: set expandtab shiftwidth=4 softtabstop=4 textwidth=78 : -->
