# vim-flavor, a tool to manage your favorite Vim plugins

[![CI](https://github.com/kana/vim-flavor/actions/workflows/ci.yml/badge.svg)](https://github.com/kana/vim-flavor/actions/workflows/ci.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/97414d95fb6d19c7fb72/maintainability)](https://codeclimate.com/github/kana/vim-flavor/maintainability)




## Getting started

    cd $YOUR_REPOSITORY_FOR_DOTFILES

    cat >Flavorfile <<'END'
      # * Declare using git://github.com/kana/vim-textobj-indent.git
      # * vim-flavor fetches git://github.com/$USER/$REPO.git
      #   if the argument is written in '$USER/$REPO' format.
      # * kana/vim-textobj-indent requires kana/vim-textobj-user.
      #   Such dependencies are automatically installed
      #   if the flavored plugin declares its dependencies with Flavorfile.
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
      
      # * For repositories without versioning, branches can be specified.
      flavor 'chriskempson/base16-vim', branch: 'master'
    END

    # Fetch the plugins declared in the Flavorfile,
    # create Flavorfile.lock for a snapshot of all plugins and versions,
    # then install the plugins into ~/.vim.
    vim-flavor install

    git add Flavorfile Flavorfile.lock
    git commit -m 'Use vim-flavor to manage my favorite Vim plugins'

See also
[the documentation on relish](https://www.relishapp.com/kana/vim-flavor) or
`features/` directory for the details.




## License

vim-flavor is released under the terms of MIT license.
See the LICENSE file for the details.




## For development

### Set up

1. Install [rbenv](https://github.com/rbenv/rbenv).
2. Run the following commands in your clone of vim-flavor repository:

   ```bash
   git submodule update --init
   rbenv install
   bundle install
   ```

### Run tests

```bash
rake test
```




## Author

* [Kana Natsuno](https://whileimautomaton.net/)
  (also known as [@kana1](https://twitter.com/kana1))




<!-- vim: set expandtab shiftwidth=4 softtabstop=4 textwidth=78 : -->
