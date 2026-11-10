# AGENTS.md

## Language

All documentation in this repository (README, AGENTS.md, code comments, commit messages) is written in **English**.

## Project

WoW addon `MyXPBarPlayedTime` (shown as "MyXPBar Played Time"): adds the time played at the current level and the total time played next to the level text of the third-party addon MyXPBar (by Polarz141, CurseForge `myxpbar-forever`), without changing MyXPBar.

- `MyXPBarPlayedTime.toc`: addon manifest, interface `16001` (WoW Forever only, Classic Era is not supported), `## Dependencies: MyXPBar`. No SavedVariables.
- `MyXPBarPlayedTime.lua`: everything. Short labels per client locale (`LOCALES`), played time tracking, the font string on the bar, events.

Key behavior:

- Played time comes from `TIME_PLAYED_MSG(total, thisLevel)`. At login the addon waits 6 s; if no addon asked for `/played` by then (FallenLevelUp and AllTheThings do), it calls `RequestTimePlayed()` itself while the chat frames are unregistered from `TIME_PLAYED_MSG` (re-registered on the answer, or after 5 s), so nothing is printed. Values are passed through `issecretvalue` checks.
- Between two answers the time is counted locally with `GetTime()`. `PLAYER_LEVEL_UP` resets the time at the level.
- MyXPBar only names its main frame (`MyXPBarFrame`). The XP bar is its first `StatusBar` child, the level text the first `FontString` region of that bar. The addon anchors its own font string to the right of the level text, uses the same font object, and follows its visibility (hooks on `SetShown`/`Show`/`Hide`, plus a 1 s ticker). If MyXPBar changes this structure, the text silently does not appear.

The Forever UI source is mirrored at https://github.com/Gethe/wow-ui-source (branch `forever`, game type "Camelot"). Check it before relying on Blizzard frame or function names.

## Installed copies

The addon is installed as a plain copy (not a clone) in:

- `C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\MyXPBarPlayedTime`

After changing the `.toc` or any `.lua`, copy them to the Forever installation. The folder name must stay `MyXPBarPlayedTime`.

## Testing

There is no automated test setup. Changes are verified in game with `/reload`; Lua errors show up with `/console scriptErrors 1`. A syntax check is possible with `luajit -bl <file>.lua`.

## Releasing

Published on CurseForge as project `1796105` (https://www.curseforge.com/wow/addons/myxpbar-played-time) and as GitHub releases. Releases are built by `.github/workflows/release.yml` with the BigWigs packager (`.pkgmeta` sets the folder name, the required dependency `myxpbar-forever` and leaves out `AGENTS.md`/`CLAUDE.md`).

1. Commit and push the changes to `main`.
2. Tag and push: `git tag -a vX.Y.Z -m "X.Y.Z"` and `git push origin vX.Y.Z` (semantic versioning).
3. The workflow packages the addon, replaces `@project-version@` in the TOC with the tag, uploads the zip to CurseForge (project ID from `X-Curse-Project-ID` in the TOC, game version from the TOC interface) and creates the GitHub release.

The upload needs the repository secret `CF_API_TOKEN`. Never edit `## Version` in the TOC by hand; installed dev copies show `@project-version@`.
