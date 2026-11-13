# Changelog

## 1.3.0

- New options window of its own: type `/uwu`. The **General** tab holds the switches, volume, cooldowns and the floating text; Esc > Options > AddOns > Forever UwU now only opens it.
- Pick your own uwus: the **Sounds** tab (`/uwu sounds`) lists every clip with a checkbox. Untick the ones you don't like and they never play; "All on" / "All off" for each kind of sound.
- The clips added in 1.2.1 got proper names.

## 1.2.1

- Many more cute sounds: crits now pick from 75 clips instead of 26 (more uwus, owos, nyans, giggles, "senpai!" and "onii-chan~"), and big hits from 39 instead of 28 (more kyaas, gasps and an unamused "really?").

## 1.2.0

- New sound pack **Hitmarker**, to pick under Options > AddOns > Forever UwU > Sound pack: your crits play the hit marker tick of old shooters and flash a hit marker over your character instead of the uwu text; a crit or big hit on you plays a sniper shot and flashes the hit marker in red. The uwus stay the default.
- Fix: crits on mobs tagged by players outside your group no longer play a sound.

## 1.1.3

- Fix: searching the game's Options (e.g. for "name") raised `ADDON_ACTION_FORBIDDEN … IsUserOAuthed()` and blamed ForeverUwU. The "Test sound" button no longer shows up in the Options search; it is still on the Forever UwU page.

## 1.1.2

- Fix: Lua error "attempt to compare local 'amount' (a secret number value)" when you get hit in combat. The client now hides hit amounts in combat; then only crits and crushing blows play the angry uwu, big normal hits don't.

## 1.1.1

- Fix: crits on mobs other than your target (Swipe, Cleave, Multi-Shot …) now play an uwu. The addon sees those mobs through their nameplates, so enemy nameplates have to be on (default key V).
- Fix: other players' crits no longer play an uwu. A crit only counts when it lands together with your own swing, shot, spell or channel. Crits from damage over time and pets stay silent.

## 1.1.0

- Many more voices: uwus from Hannah OwO, Pokimane, Ironmouse, Gawr Gura, Kobo, Neuro-sama and more, plus tuturu, nyanpasu and nico nico nii. More ara aras, Chika's "hiiih!" and a few more angry sounds for big hits.
- Every clip now starts right on the voice and ends without a pause, and carries no leftover metadata.
- New **Sounds** page under the options: every clip as a button to play it. `/uwu sounds` opens it.

## 1.0.1

- Fix: a crit on the opening hit of a fight (for example the first Arcane Missile) now plays an uwu. It was dropped because the client marks you as in combat only after that hit.

## 1.0.0

- Initial release: a random uwu on your crits and crit heals, small quiet uwus when crits come fast, and an angry uwu / ara ara when you get crit or take a big hit.
- Floating uwu text over your character with every sound, in a cute anime font.
- Options under Esc > Options > AddOns > Forever UwU: volume with test button, cooldowns, big-hit threshold. `/uwu` opens them.
