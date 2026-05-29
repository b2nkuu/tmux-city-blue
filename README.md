# tmux-city-blue

Personal tmux 3.x configuration — modular `conf.d/` layout, custom status-bar
scripts, and a vendored **citypop-tn** theme (fork of
[janoamaral/tokyo-night-tmux](https://github.com/janoamaral/tokyo-night-tmux)).

> Tested on macOS with tmux 3.6b. Some helpers assume `pbcopy`, `osascript`,
> and a Nerd Font.

## Layout

```
tmux.conf           # entrypoint, source-file's into conf.d/
conf.d/             # modular configuration
  general.conf      # terminal caps, behavior, status shell
  keybinds.conf     # prefix maps, mouse, popups, menus
  theme.conf        # citypop-tn theme options
  plugins.conf      # tpm plugin list + per-plugin options
scripts/            # status-bar widgets (cpu, ram, git, k8s, weather, …)
themes/
  citypop-tn/       # vendored theme fork
  build-citypop.sh  # rebuild theme from upstream
  citypop-osaka.conf
  status-git.sh
install.sh          # symlink the repo into $HOME (with backups)
```

## Install

```bash
git clone https://github.com/b2nkuu/tmux-city-blue.git ~/code/tmux-city-blue
cd ~/code/tmux-city-blue
./install.sh
```

`install.sh` is idempotent:

- backs up any existing real `~/.tmux.conf`, `~/.tmux/conf.d`, `~/.tmux/scripts`,
  `~/.tmux/themes` with a timestamp suffix
- replaces them with symlinks into this repo
- clones `tmux-plugins/tpm` into `~/.tmux/plugins/tpm` if missing
- leaves `~/.tmux/plugins/` (managed by tpm) alone

After install, open tmux and press **prefix + I** to install plugins.

## Plugins (tpm)

`tmux-sensible`, `tmux-yank`, `tmux-resurrect`, `tmux-continuum`, `tmux-cpu`,
`tmux-battery`, `tmux-weather`, `tmux-open`, `extrakto`, `tmux-sessionx`,
`tmux-floax`, `tmux-pomodoro-plus`, `tmux-fzf`, `vim-tmux-navigator`.

The theme is **not** loaded via tpm — it runs after tpm via `run-shell` so the
citypop palette wins (see `tmux.conf`).

## Credits

- Theme: [janoamaral/tokyo-night-tmux](https://github.com/janoamaral/tokyo-night-tmux)
  (MIT — see `LICENSE`). `themes/citypop-tn/` is a vendored fork with a custom
  citypop palette and tweaked widgets.

## License

MIT — inherited from the vendored theme. See `LICENSE`.
