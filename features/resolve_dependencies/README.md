Vim plugins sometimes require other plugins as libraries.  For example,
[vim-textobj-entire](https://github.com/kana/vim-textobj-entire) provides text
objects to deal with the entire text in the current buffer.  But it is hard to
properly implement text objects because of many pitfalls and repetitive
routines.  So that vim-textobj-entire uses
[vim-textobj-user](https://github.com/kana/vim-textobj-user) to define text
objects in a simplified and declarative way.  Therefore, if user wants to use
vim-textobj-entire, he or she must install both vim-textobj-entire and
vim-textobj-user.

But it is a boring task to install dependencies by hand.  Even if the authors
of a plugin noted about dependencies in its document, such notes are often
overlooked.

So that `vim-flavor` automatically resolves dependencies of Vim plugins.  If
a plugin declares its dependencies as a [flavorfile](flavorfile) and saves it
as `VimFlavor`, `vim-flavor` reads the file and automatically installs
dependencies according to the file.

`vim-flavor` also takes care about versions of Vim plugins.  If two plugins
require the same plugin but required versions are not compatible to others,
installation will be stopped to avoid using Vim with a broken configuration.




<!-- vim: set expandtab shiftwidth=4 softtabstop=4 textwidth=78 : -->
