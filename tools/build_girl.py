"""Renders the options window mascot media/girl.svg to textures/girl.tga.

Draws the SVG with headless Chrome at 4x on a transparent background, then
scales it down with Pillow. WoW wants power-of-two sizes: 256x512.

Usage:  python tools/build_girl.py   (needs Chrome or Edge and Pillow)
"""

import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SVG = ROOT / "media" / "girl.svg"
OUT = ROOT / "textures" / "girl.tga"
SIZE = (256, 512)
SCALE = 4

BROWSERS = [
    r"C:\Program Files\Google\Chrome\Application\chrome.exe",
    r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
    "google-chrome",
    "chromium",
]


def browser():
    for candidate in BROWSERS:
        if Path(candidate).exists() or shutil.which(candidate):
            return candidate
    sys.exit("Chrome or Edge not found")


def main():
    with tempfile.TemporaryDirectory() as tmp:
        png = Path(tmp) / "girl.png"
        subprocess.run([
            browser(), "--headless", "--disable-gpu", "--hide-scrollbars",
            f"--user-data-dir={tmp}",
            f"--window-size={SIZE[0]},{SIZE[1]}",
            f"--force-device-scale-factor={SCALE}",
            "--default-background-color=00000000",
            f"--screenshot={png}",
            SVG.as_uri(),
        ], check=True, capture_output=True)
        img = Image.open(png).convert("RGBA").resize(SIZE, Image.LANCZOS)
    img.save(OUT)
    print(f"wrote {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
