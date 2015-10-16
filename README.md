[Tim](https://github.com/hellowor1dn)'s dotfiles
=====

## Setup

To setup the [dotfiles](dotfiles) just run the appropriate snippet in the terminal:

| OS | Snippet |
|:---:|:---|
| OS X | ```bash -c "$(curl -LsS https://raw.github.com/hellowor1dn/dotfiles/master/dotfiles)"``` |

This will:

* Download these dotfiles to `~/dotfiles`
* Create directories: `~/work`, `~/code`, `~/bin`, `~/Downloads/torrents`
* Symlink some dotfiles
* Install tools, apps, and relevant plugins
* Set preferences

## Update

To update the dotfiles, run the [bootstrap](script/bootstrap) script.

## Style guide

* [Google Shell Style](https://google-styleguide.googlecode.com/svn/trunk/shell.xml)

## Resources

* [BashFAQ](http://mywiki.wooledge.org/BashFAQ)

## [Contributing](CONTRIBUTING.md)

In the event that someone other than me stumbles upon this repository: these
dotfiles are really just for me. Most of the content is code taken from
[awesome people](https://github.com/hellowor1dn/dotfiles#Acknowledgements).
That being said, feel free to use my scripts as inspiration for your own.

## Acknowledgements

Inspiration and code was taken from many sources, including:

* [Mathias Bynens'](https://github.com/mathiasbynens)
  [dotfiles](https://github.com/mathiasbynens/dotfiles)
* [Cătălin Mariș'](https://github.com/alrra)
  [dotfiles](https://github.com/alrra/dotfiles)

You da real MVPs.

## License

The code is available under the [MIT license](LICENSE.md).
