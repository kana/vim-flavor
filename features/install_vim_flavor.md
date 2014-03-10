## Required softwares

* [Git](http://git-scm.com/) 1.7.9 or later
* [Ruby](http://www.ruby-lang.org/) 2.0.0 or later
  * Recommendation: Use [RVM](http://beginrescueend.com/) or other tools
    for ease of installation across different envinronments.
* [Vim](http://www.vim.org/) 7.3 or later
  * Note that Vim should be compiled as normal, big or huge version
    to use most of plugins.




## Supported platforms

* Unix-like environments such as Linux, Mac OS X, etc.
* Though Microsoft Windows is not directly supported,
  it is possible to manage Vim plugins via Cygwin or other environments.




## Installation steps

    gem install vim-flavor

    cd $YOUR_REPOSITORY_FOR_DOTFILES

    # Add the following line into the first line of your vimrc:
    #
    #   runtime flavors/bootstrap.vim
    vim vimrc

    touch VimFlavor VimFlavor.lock

    git add VimFlavor VimFlavor.lock vimrc
    git commit -m 'Use vim-flavor to manage my favorite Vim plugins'




<!-- vim: set expandtab shiftwidth=4 softtabstop=4 textwidth=78 : -->
