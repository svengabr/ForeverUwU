"""Draws the textures (textures/*.tga) for the floating uwu text over the character.

  heart.tga      small heart next to crit uwus, white with a dark outline, so
                 the addon can tint it
  hitmarker.tga  four diagonal ticks around an empty middle for the hitmarker
                 sound pack, white with a thin dark outline, tinted the same way

Usage:  python tools/build_textures.py   (needs Pillow)
"""

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "textures"
SS = 4  # supersampling
OUTLINE = (58, 8, 32, 255)


def heart_shape(size, inset):
    s = size
    m = Image.new("L", (s, s), 0)
    d = ImageDraw.Draw(m)
    r = s * 0.27 - inset
    d.ellipse((s * 0.22 - r, s * 0.36 - r, s * 0.22 + r + s * 0.06, s * 0.36 + r), fill=255)
    d.ellipse((s * 0.72 - r - s * 0.06, s * 0.36 - r, s * 0.72 + r + s * 0.06, s * 0.36 + r), fill=255)
    d.rectangle((s * 0.34, s * 0.36, s * 0.66, s * 0.62), fill=255)
    d.polygon([(s * 0.06 + inset, s * 0.46), (s * 0.94 - inset, s * 0.46), (s * 0.5, s * 0.92 - inset * 1.4)], fill=255)
    return m


def heart():
    s = 64 * SS
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    img.paste(Image.new("RGBA", (s, s), OUTLINE), (0, 0), heart_shape(s, 0))
    img.paste(Image.new("RGBA", (s, s), (255, 255, 255, 255)), (0, 0), heart_shape(s, 5 * SS))
    return img.resize((64, 64), Image.LANCZOS)


def hitmarker():
    s = 64 * SS
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Each tick runs from near a corner towards the middle and stops short of it.
    outer, inner = 0.14, 0.36
    for width, color in ((7 * SS, (0, 0, 0, 200)), (4 * SS, (255, 255, 255, 255))):
        for dx, dy in ((0, 0), (1, 0), (0, 1), (1, 1)):
            x0 = s * (outer if dx == 0 else 1 - outer)
            y0 = s * (outer if dy == 0 else 1 - outer)
            x1 = s * (inner if dx == 0 else 1 - inner)
            y1 = s * (inner if dy == 0 else 1 - inner)
            d.line([(x0, y0), (x1, y1)], fill=color, width=width)
    return img.resize((64, 64), Image.LANCZOS)


if __name__ == "__main__":
    OUT.mkdir(exist_ok=True)
    for old in ("bubble.tga", "tail.tga", "glow.tga"):
        (OUT / old).unlink(missing_ok=True)
    heart().save(OUT / "heart.tga")
    hitmarker().save(OUT / "hitmarker.tga")
    print("textures written to", OUT)
