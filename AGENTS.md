# AGENTS.md

Notes for AI agents (Claude Code, Codex, Cursor …) working on ForeverUwU.

## What the addon does

WoW addon that plays a random anime "uwu" when the player lands a critical hit or heal, and an angry uwu /
"ara ara" when the player takes a critical hit or a single hit of at least `hurtPercent` (default 25 %) of their
maximum health. Everything lives in `ForeverUwU.lua`.

**No combat log:** on WoW: Forever, registering `COMBAT_LOG_EVENT_UNFILTERED` is a forbidden action for addons
(`ADDON_ACTION_FORBIDDEN`). The addon uses `UNIT_COMBAT` for `player` and `target` instead (flags `CRITICAL` /
`CRUSHING`, events `WOUND` / `HEAL`). It carries no source: a crit on the target counts as the player's own while
the player is in combat, so in a group other players' crits on the same target trigger it too.

- **Pools:** `crit` (full uwu), `small` (short quiet uwu), `hurt` (angry uwu / ara ara). Each pool is a shuffle
  bag: every clip plays once before one repeats.
- **Throttle:** a full crit uwu plays at most every `critCooldown` s (default 1.5); crits in between play a small
  uwu, at most every 0.2 s (`SMALL_GAP`). Hurt sounds have their own `hurtCooldown` (default 3 s) and also reset
  the crit cooldown so the two don't talk over each other.
- **Floating text:** `Bubble.lua` (`ns.ShowBubble`) pops a short text per pool over the screen center (addons can't
  read the character's screen position; the default camera keeps it centered), offset `bubbleX` / `bubbleY`. Font
  `fonts/MochiyPopOne-Regular.ttf` (SIL OFL, `fonts/OFL.txt`), subset to Latin with
  `pyftsubset --unicodes="U+0020-007E,U+00A0-00FF,U+2014,U+2019,U+201C,U+201D,U+2026,U+2661,U+2665,U+FF5E"`.
  `textures/heart.tga` comes from `python tools/build_textures.py`. A font or texture path that doesn't exist is a
  Lua error in the client, not a silent fallback. Values from `UnitHealth` of other units are secret in combat
  and must not be compared.
- **Options:** Esc > Options > AddOns > Forever UwU, SavedVariable `ForeverUwUDB`. `/uwu` opens them,
  `/uwu crit|small|hurt` plays a test sound. Sounds play on the Master channel.

## Sounds

WoW can't list files, so every clip is named in a generated Lua file:

| Set | Raw clips (git-ignored) | Output | List |
|---|---|---|---|
| public | `raw/public/<pool>/` | `sounds/<pool>/*.ogg` | `Sounds.lua` |
| local | `raw/local/<pool>/` | `sounds/local/<pool>/*.ogg` (git-ignored) | `SoundsLocal.lua` (git-ignored) |

Run `python tools/build_sounds.py` after changing raw clips (needs ffmpeg). It trims silence, makes mono 44.1 kHz,
loudness-normalizes and encodes Ogg Vorbis. Without a `small` folder, small uwus are derived from the crit clips.

**Public set = the shipped sounds.** The maintainer decided (2026-10-07) to ship the myinstants meme clips
(cute uwu, owo, ara ara, kyaa, itai, baka …) in the public set, knowing they are not freely licensed and could
draw a DMCA takedown; `CREDITS.md` names the source and offers removal on request. The local set (`raw/local`,
`SoundsLocal.lua`, in a `#@do-not-package@` block and `.pkgmeta` `ignore`) stays for clips that should never be
packaged. 23 Freesound clips (CC0 / CC BY) were tried and dropped as not good enough (`raw/unused/freesound/`).
No sexually explicit sounds in the public set (CurseForge content rules).

## Rules

- **English only in the repo**: code comments, commit messages, `AGENTS.md`, `CHANGELOG.md`, `README.md` and
  workflow files.
- Played and tested only on WoW: Forever (Interface 16001, Blizzard UI source: Gethe/wow-ui-source, branch
  `forever`).
- Commit messages follow Conventional Commits (`feat:`, `fix:`, `chore:` …).
- The README is also the **CurseForge project description**. CurseForge can't take it over via API; after README
  changes, remind the maintainer to paste it there by hand.

## Checks

There are no unit tests. In-game behavior can only be checked in the client; say so honestly.

**luacheck:** `.luacheckrc` lists every global the addon uses; add new globals there.
Locally without a Lua install via Docker (PowerShell):
`docker run --rm -v "${PWD}:/data" -w /data ghcr.io/lunarmodules/luacheck .`

It runs in `.github/workflows/test.yml` on push and pull request; the release workflow only starts after a green
check.

## Release

Publishing is automatic via `.github/workflows/release.yml` (BigWigsMods/packager) to CurseForge (project ID in
the TOC as `X-Curse-Project-ID`) and GitHub Releases. It runs **only on tags** `v*`, never on a plain push.

1. Add the new version to `CHANGELOG.md` and commit.
2. Create an annotated tag `vX.Y.Z` and push it; that starts the upload.

Don't replace `## Version: @project-version@` by hand, the packager sets it from the tag.
New files or folders that don't belong in the addon ZIP go into `.pkgmeta` under `ignore`.
Tags and pushes only after the maintainer approves.
