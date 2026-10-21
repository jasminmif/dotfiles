# dotfiles

Dotfile workstation setup scripts

## How to use

Clone this in your home directory `cd ~ && git clone https://github.com/jasminmif/dotfiles.git`
than run `sh install.sh`

## Syncing settings between Macs (`dotsync`)

`sync/dotsync` keeps macOS settings (mouse, trackpad, keyboard, Dock, Finder…) and app
settings in sync across your Macs through this repo. What it syncs is listed in
[`sync/tracked.conf`](sync/tracked.conf); the saved values live in `configs/`.

```sh
dotsync push     # save this Mac's settings, commit and push to main
dotsync pull     # get the latest settings from main and apply them here
dotsync status   # see which of this Mac's settings differ from the repo
dotsync track    # change a setting, and dotsync finds its key and starts tracking it
dotsync apply    # re-apply configs/ to this Mac without touching git
```

- **New Mac:** run `sh install.sh`, then `dotsync pull`. The first pull only takes
  settings from main; it never pushes this Mac's defaults over them.
- **Conflicts:** if this Mac and main changed the same setting, dotsync asks whether to
  keep this Mac's settings, take main's, or have Claude Code merge both. After a Claude
  merge, run `dotsync push` to send the merged settings to your other Macs.
- **App settings:** whole config files are copied with [Mackup](https://github.com/lra/mackup)
  (`mackup <app>` lines). For apps whose config file also holds account data, like
  Claude, track single keys with a `json` line instead.
- **This repo is public.** dotsync stops before committing anything that looks like a
  token or password, but check what you add to `tracked.conf`.
