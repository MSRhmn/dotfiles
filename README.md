# msrhmn's Dotfiles 🐧

A Simple, and quick Linux desktop setup, just things that work.

### What this is
My personal dotfiles for a fast, minimal, and stable Linux daily driver so that I don't have to bother for update's or a new installation.

### Distro & Environment
- Ubuntu 24.04 LTS (currently)
- Default GNOME Terminal
- Shell: Bash with a few quality of aliases
- Editor: VS Code, vi when I'm on a server or in terminal

### How to use these dotfiles
This repo is made since **Ubuntu 20.04/22.04/24.04** and so on with default GNOME + bash. It will probably work fine on Debian/Pop!_OS/Linux Mint too.

#### Option 1 - Quick & safe (recommended for most people)
Just look around and copy what you like manually.
Most files are tiny and self-explanatory.

#### Option 2 - Selective install
```bash
# Clone anywhere you want
git clone https://github.com/msrhmn/dotfiles.git ~/dotfiles

# Then copy only what you need, e.g.:
cp ~/dotfiles/.bashrc ~/.bashrc
cp ~/dotfiles/.bash_aliases ~/.bash_aliases
```

#### Git identity and signing
The tracked `.gitconfig` contains shared preferences and loads personal settings
from `~/.gitconfig.local`. Before making commits, create that file from the
template and replace the example name and email with your own:

```bash
cp ~/dotfiles/.gitconfig.local.example ~/.gitconfig.local
${EDITOR:-vi} ~/.gitconfig.local
```

The local file is not tracked by this repository, so your email and signing key
stay on your machine.

Spotify installation is optional because Spotify's Linux client may not support
every Ubuntu release. To opt in when running the installer, use
`INSTALL_SPOTIFY=1 ./install_script.sh`.

## License
© 2025 Md. Shamim Rahman<br>
This project is licensed under the [MIT License](LICENSE) - see the LICENSE file for details.  
Feel free to use, fork, modify, or redistribute it however you like.

Inspired by the awesome work of **@CoreyMSchafer** → [github.com/CoreyMSchafer/dotfiles](https://github.com/CoreyMSchafer/dotfiles)
