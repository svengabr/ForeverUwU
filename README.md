# Forever UwU

<img src="https://raw.githubusercontent.com/svengabr/ForeverUwU/main/media/logo.png" alt="Forever UwU logo" width="128">

A silly little addon for **World of Warcraft: Forever**: every crit deserves an uwu.

- **You crit:** a random anime uwu plays when you land a critical hit or heal. Every clip plays once before any repeats.
- **Crits come fast?** Between full uwus (at most one every 1.5 s) you get small, quiet uwus instead of a wall of noise.
- **You get crit or take a big hit:** an angry uwu, an ara ara or a startled kyaa. A big hit is one that takes at least 25 % of your maximum health.
- **Floating uwu text:** every sound pops a cute "uwu~", "owo~" or "ara ara~" over your character, like the game's crit numbers. Only you see it.

All sounds are leveled to the same loudness.

![Every crit deserves an uwu](https://raw.githubusercontent.com/svengabr/ForeverUwU/main/media/gallery/01-overview.jpg)

![Crit you? Ara ara~](https://raw.githubusercontent.com/svengabr/ForeverUwU/main/media/gallery/02-hurt.jpg)

## Options

Open **Esc > Options > AddOns > Forever UwU**, or type `/uwu`.

- **Volume** with a **Play uwu** test button. Sounds play on the Master channel.
- Crit uwus, small uwus, angry uwus and the floating text can each be switched off.
- Position of the floating text. Your character stands in the middle of the screen, so it sits at an offset from there.
- Cooldowns for full and angry uwus, and the big-hit threshold.
- **Sounds** page below it: every clip as a button, to hear each one. `/uwu sounds` opens it.

Test sounds: `/uwu crit`, `/uwu small`, `/uwu hurt`.

![Options](https://raw.githubusercontent.com/svengabr/ForeverUwU/main/media/gallery/03-options.jpg)

## Good to know

WoW: Forever doesn't let addons read the combat log. Forever UwU uses the same hit events as the damage numbers on your unit frames instead. Those don't say who hit, so in a group your party's crits on your target can trigger an uwu too. Crits that kill a mob come without the crit flag; the addon guesses those from the hit size.

## Install

1. Download the latest release zip.
2. Extract it so you have `World of Warcraft\_classic_beta_\Interface\AddOns\ForeverUwU`.
3. Restart the game.

## Sounds

See [CREDITS.md](CREDITS.md) for where the clips come from. The floating text uses Mochiy Pop One (SIL Open Font License, `fonts/OFL.txt`).

## Support

The addon is free and always will be. If it made your game a bit cuter, you can [buy me a coffee](https://buymeacoffee.com/conoar).
