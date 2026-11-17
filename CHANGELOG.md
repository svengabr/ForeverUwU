# Changelog

## Unreleased

- **Seconds between full uwus** now goes up to 30 s (was 5 s), in steps of 0.5 s, so a full uwu can stay special when crits come often.

## 1.6.0

- New crit counter: every crit of yours counts, per character and per session. `/uwu` shows this session's crits and the total with a reset button, **Crit count in the text** shows the count under the floating text ("#128"), and **Crit counter on screen** adds a small box you can drag anywhere. Both are off by default.
- The MLG pack gets 17 more clips: esport and arena shooter announcer calls on your crits ("Headshot!", "Boom headshot!", "Double kill", "Triple kill!", "Killing spree", "Dominating!", "Godlike!", "Unstoppable!", "Rampage!", "First blood", "Impressive!") and more fails when you get hit ("You have been slain", "Game over", "Game over, man!", "Noooo!", "Why, bro?", a fail trumpet), with new captions like "HEADSHOT" and "GAME OVER".
- The floating text now fits the sound that plays: "DAMN SON" for "Damn son!", "ara ara~" for an ara ara, "nyan~" for a nyan and so on, in the uwu and the MLG pack.
- Milestone cheers: your 100th, 500th, 1,000th, 2,500th, 5,000th and every 10,000th crit gets a cheer and a big "1,000 CRITS!" popup. Test with `/uwu milestone`.
- Sound when you die: "Wasted", "Mission failed", "You have been slain" or "Game over" in the MLG pack, "that hurt, senpai!" or "itai!" in the uwu pack. Test with `/uwu death`.
- The crit count now also remembers your biggest crit ("best 1,234" in `/uwu` and the counter box), as far as the game shows the amounts: in combat it often hides them.
- Hatsune Miku joins the uwu pack: "Miku dayo~", "Oh, hey!", "Oh, thank you~", "Hello?", "Hmm?" and the SEGA jingle on your crits, "Nani!?" and a scream when you get hit.
- The options window has a live preview: the floating text, the crit count under it, a small uwu, the hurt text, the milestone popup and the counter box, in your sound pack's look. Switched-off parts show faded with "off", and hovering an option pops its part.
- The floating text is a bit smaller.
- The X of the options window now also closes it in combat.
- The MLG pack button in the options now has its own tooltip.

## 1.5.0

- New sound pack **MLG**, to pick with `/uwu` > Sound pack: your crits play montage parody classics ("Damn son!", "Oh baby a triple!", "Wombo combo!", "Wow", air horns …) with loud green captions like "360 NO SCOPE"; a crit or big hit on you plays "Emotional damage!", "Mission failed", "Oof", "Bruh" and the sad violin. Short clips from Bill Sussman's MLG voice pack for the PlanetSide 2 Recursion tracker plus MLG favorites from myinstants.com.

## 1.4.0

- Crit heals are now opt-in: switch on **Also on my crit heals** under `/uwu`. Off by default.
- New options **Off in a party** and **Off in a raid**: no uwus while you are in a group, where other players' crits sometimes slip through. Both off by default.
- A cute cat-ear girl with a heart now keeps you company in the options window.

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
