# Gallery images

Source for the CurseForge gallery: one HTML page per image (1920×1080), shared look in `style.css`
(same frame as ForeverLootSparkles and ForeverMinimapTarget). Everything is drawn in HTML/CSS plus `../logo.png`.

Render all pages to JPG (or a single one with `sh render.sh 02-hurt.html`):

```sh
sh render.sh
```

Not in the repo (git-ignored), put them in place before rendering:

- `fonts/MochiyPopOne-Regular.ttf`: `cp ../../fonts/MochiyPopOne-Regular.ttf fonts/`
- `fonts/FRIZQT__.TTF`: `curl -L -o fonts/FRIZQT__.TTF https://wago.tools/api/casc/615960`
