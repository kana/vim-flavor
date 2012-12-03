## Short summary

1. Write tests for your Vim plugin with
   [vim-vspec](https://github.com/kana/vim-vspec).
2. Declare dependencies of your Vim plugin as a [flavorfile](flavorfile), and
   save it as `VimFlavor` in the root of your Vim plugin.
3. Run `vim-flavor test`.




## Long story

It is hard to test Vim plugins, because there are a few problems:

* It is hard to write readable and maintainable test code in Vim script, even
  for skilled users.  Because Vim script is not expressive as script languages
  like Ruby and others.
* Each test must be run in an isolated environment to guarantee the same
  results for every time and everywhere.  So that all settings including vimrc
  and plugins must be ignored.  User's viminfo must not be read and written
  too.
* Some plugins require other plugins at runtime.  Such dependencies must be
  resolved, but they must be installed into a temporary place to avoid
  corrupting user's settings.  And `'runtimepath'` must be configured
  carefully for both dependencies and plugins under development.

Therefore it is hard to do right testing for Vim plugins from scratch.  As
a lazy Vim user, I want to abstract all of the complexity.

Fortunately, the problems can be solved partially with
[vim-vspec](https://github.com/kana/vim-vspec), a testing framework for Vim
script.  It provides a DSL based on Vim script to write readable test code.
It provides also a driver script to run tests.  The driver script hides
details about the isolation of Vim processes and `'runtimepath'`
configuration.

However, vim-vspec is a tool to write tests, not a tool to set up environment
to test.  So that it does nothing about dependencies.  And it is painful to
manage dependencies by hand.  But it is easy with vim-flavor.  The complexity
can be hidden by combining both tools.  That's why vim-flavor is integrated
with vim-vspec.




<!-- vim: set expandtab shiftwidth=4 softtabstop=4 textwidth=78 : -->
