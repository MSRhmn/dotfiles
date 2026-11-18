# msrhmn's Dotfiles 🐧

Personal Bash, desktop, and development setup for an Ubuntu daily driver. The
repository includes shell configuration, setup and update scripts, and common
tools for Python and Django development.

## Environment

- Ubuntu Desktop with Bash and GNOME
- VS Code for development; `vi` for terminal editing
- Python 3, `pip`, `venv`, and Black for Python projects

The scripts target Ubuntu and use APT. Review them before running, since setup
installs packages and configures third-party repositories.

## Python and Django projects

Python and Django dependencies belong in each project's virtual environment,
rather than being installed globally by these dotfiles. For a project that has
a `requirements.txt` file:

```bash
cd ~/projects/my-django-project
python3 -m venv venv
source venv/bin/activate
python -m pip install -r requirements.txt
python manage.py runserver
```

The `p` shell alias changes to `~/projects`. Add project dependencies to that
project's `requirements.txt` so they can be recreated on another machine.

## Setup

Clone the repository:

```bash
git clone https://github.com/msrhmn/dotfiles.git ~/dotfiles
```

You can copy individual configuration files, or run `make_symlinks.sh` to link
the Bash and Git configuration files and add the setup scripts to `~/bin`.
If a destination already exists, the script moves it into a timestamped folder
under `~/.dotfiles-backup/` before creating the symlink. Correct existing links
are left in place. The backup directory is created on every run; a timestamped
backup folder is created only when there is something to preserve.

Run `install_script.sh` to install the listed desktop and development tools.
Run `update_script.sh` for system and Node.js updates. Spotify is optional; opt
in by running the installer with `INSTALL_SPOTIFY=1`.

## Git identity and signing

The tracked `.gitconfig` loads personal settings from `~/.gitconfig.local`.
Create it from the template and replace the example name, email, and key path:

```bash
cp ~/dotfiles/.gitconfig.local.example ~/.gitconfig.local
${EDITOR:-vi} ~/.gitconfig.local
```

The local file is not tracked, keeping personal settings out of this repository.

## License

© 2025 Md. Shamim Rahman<br>
This project is licensed under the [MIT License](LICENSE) - see the LICENSE
file for details. Feel free to use, fork, modify, or redistribute it.
