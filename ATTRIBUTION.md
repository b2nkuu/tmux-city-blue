# Attribution

`city-blue` is a derivative of two upstream projects.

## Lineage

```
janoamaral/tokyo-night-tmux  →  citypop-tn (private fork)  →  city-blue
```

- **Original:** [janoamaral/tokyo-night-tmux](https://github.com/janoamaral/tokyo-night-tmux) — MIT.
- **Intermediate:** `citypop-tn`, a vendored fork that added the citypop (Blue Ocean) palette.
- **This repo:** strips everything not used by the city-blue setup; widget code and palette are owned here.

## What was removed from the upstream

- Themes other than citypop (moon, storm, day, default) — only the citypop palette survives, as
  `scripts/citypop/lib/palette.sh`.
- Widgets not wired into the status line: `music-tmux-statusbar.sh`, `wb-git-status.sh`,
  `cmus-tmux-statusbar.sh`, `os-icons.sh`.
- Repo cruft: upstream `README.md`, `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `SECURITY.md`,
  `LICENSE.md`, `.github/`, `test/`, `snaps/`, `user_docs/`.
- The runtime dispatcher (`tokyo-night.tmux`); its logic is now baked into `build.sh`,
  which emits a static `themes/city-blue.conf`.

## What was changed

- **Namespace:** all tmux options renamed from `@tokyo-night-tmux_*` to `@city-blue_*`. Configure
  via `conf.d/theme.conf`.
- **Path layout:** widgets live under `scripts/citypop/` (sibling `lib/` for `palette.sh`,
  `coreutils-compat.sh`, `netspeed-core.sh`). Each script resolves siblings via `ROOT_DIR`
  computed from `BASH_SOURCE`.
- **Build model:** instead of `run-shell tokyo-night.tmux` mutating tmux options at session
  start, `build.sh` writes a single `themes/city-blue.conf` that `~/.tmux.conf` sources directly.

## What was kept verbatim (modulo path/namespace patches)

- `scripts/citypop/git-status.sh`
- `scripts/citypop/netspeed.sh`
- `scripts/citypop/battery-widget.sh`
- `scripts/citypop/path-widget.sh`
- `scripts/citypop/hostname-widget.sh`
- `scripts/citypop/datetime-widget.sh`
- `scripts/citypop/custom-number.sh`
- `scripts/citypop/disk-widget.sh`
- `scripts/citypop/weather-icon.sh`
- `scripts/citypop/weather-text.sh`
- `scripts/citypop/lib/coreutils-compat.sh`
- `scripts/citypop/lib/netspeed-core.sh` (was `lib/netspeed.sh` upstream)

## License

Upstream MIT terms apply to the ported widgets. `LICENSE` at the repo root is the original MIT
notice for tokyo-night-tmux, retained for provenance.
