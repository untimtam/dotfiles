[Tim](https://github.com/hellowor1dn)'s dotfiles
=====

## Setup

Please only continue if you know what you're doing...
To setup the [dotfiles](dotfiles) just run the appropriate snippet in the terminal:

| OS | Snippet |
|:---:|:---|
| macOS | ```bash -c "$(curl -LsS https://raw.github.com/hellowor1dn/dotfiles/master/dotfiles)"``` |
| Ubuntu | ```bash -c "$(wget -qO - https://raw.github.com/hellowor1dn/dotfiles/master/dotfiles)"``` |

Warning: Ubuntu configuration is not completed!  

This will:

* Download these dotfiles to `~/dotfiles`
* Create directories: `~/bin`, `~/code`, `~/projects`, `~/work`, `~/Downloads/torrents`
* copy bin scripts
* Symlink some dotfiles
* Install tools, apps, other stuff
* Set preferences

## Post-setup

See the [macOS Post-Setup](POST_SETUP.md) file.

## Update

To update the dotfiles, run the [bootstrap](script/bootstrap) script.

## Style guide

* [Google Shell Style](https://google-styleguide.googlecode.com/svn/trunk/shell.xml)

## Resources

* [BashFAQ](http://mywiki.wooledge.org/BashFAQ)
* [BASH manual](https://www.gnu.org/software/bash/manual/bash.html)
* [Bash Exit Codes](http://tldp.org/LDP/abs/html/exitcodes.html)
* [Bash Testing](http://pubs.opengroup.org/onlinepubs/9699919799/utilities/test.html)

## TODO:

* finish update script
* vim and vim packges
* verification step
* add post-install preferences to install
* extra packages for some tools (opam init) (python, ruby, ocaml/opam, etc)
* These dotfiles only work from `~/dotfiles`?

## Adding (?):
- [] update gnu utils
- [] teamspeak
- [] GitUp
- [] StarUML
- [] Tor/Torbrowser
- [] rust packages?

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
