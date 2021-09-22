## Required softwares

* [Git](https://git-scm.com/) 2.10.1 or later
* [Ruby](https://www.ruby-lang.org/) 3.0.0 or later
  * Recommendation: Use [rbenv](https://github.com/rbenv/rbenv) or other tools
    for ease of installation across different envinronments.
* [Vim](https://www.vim.org/) 8.0 or later
  * Note that Vim should be compiled as normal, big or huge version
    to use most of plugins.




## Supported platforms

* Unix-like environments such as Linux, Mac OS X, etc.
* Though Microsoft Windows is not directly supported,
  it is possible to manage Vim plugins via Cygwin or other environments.




## Installation steps

    gem install vim-flavor

    cd $YOUR_REPOSITORY_FOR_DOTFILES

    touch Flavorfile Flavorfile.lock
    git add Flavorfile Flavorfile.lock
    git commit -m 'Use vim-flavor to manage my favorite Vim plugins'




<!-- vim: set expandtab shiftwidth=4 softtabstop=4 textwidth=78 : -->
