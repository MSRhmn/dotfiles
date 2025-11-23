# msrhmn's Dotfiles 🐧

A Simple, and quick Ubuntu desktop setup, just things that work.

### What this is
My personal dotfiles for a fast, minimal, and stable Ubuntu daily driver so that I don't have to bother for update's or a new installation.

### Distro & Environment
- Ubuntu 24.04 LTS (currently)
- Default GNOME Terminal
- Shell: Bash with a few quality of aliases
- Editor: VS Code, vi when I'm on a server or in terminal

### How to use these dotfiles
This repo is made since **Ubuntu 20.04/22.04/24.04** and so on with default GNOME + bash.  
It will probably work fine on Debian/Pop!_OS/Linux Mint too.

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

