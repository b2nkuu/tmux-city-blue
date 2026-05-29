# tmux-city-blue

Personal tmux 3.x configuration — modular `conf.d/` layout, custom status-bar
scripts, and the **city-blue** theme (standalone, native tmux DSL, no theme
plugin required).

> Tested on macOS with tmux 3.6b. Some helpers assume `pbcopy`, `osascript`,
> and a Nerd Font.

## Layout

```
tmux.conf           # entrypoint, source-file's into conf.d/ + theme
conf.d/             # modular configuration
  general.conf      # terminal caps, behavior, status shell
  keybinds.conf     # prefix maps, mouse, popups, menus
  plugins.conf      # tpm plugin list + per-plugin options
scripts/            # status-bar widgets (cpu, ram, git, k8s, weather, …)
themes/
  city-blue.conf      # generated status-line (sourced from tmux.conf)
  build-city-blue.sh  # regenerate city-blue.conf with Nerd Font glyphs
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

## Theme

`themes/city-blue.conf` is a self-contained status-line written in native tmux
DSL — no `tokyo-night-tmux` (or any theme plugin) needed at runtime. To tweak
glyphs or palette, edit `themes/build-city-blue.sh` and re-run it:

```bash
bash themes/build-city-blue.sh && tmux source ~/.tmux.conf
```

The layout was originally inspired by
[janoamaral/tokyo-night-tmux](https://github.com/janoamaral/tokyo-night-tmux);
this repo carries no upstream code.

## Plugins (tpm)

`tmux-sensible`, `tmux-yank`, `tmux-resurrect`, `tmux-continuum`, `tmux-cpu`,
`tmux-battery`, `tmux-weather`, `tmux-open`, `extrakto`, `tmux-sessionx`,
`tmux-floax`, `tmux-pomodoro-plus`, `tmux-fzf`, `vim-tmux-navigator`.

## License

MIT — see `LICENSE`.
