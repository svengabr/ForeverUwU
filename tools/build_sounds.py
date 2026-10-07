"""Turns raw clips into the addon's .ogg files and writes the Lua sound list.

WoW can't list files in a folder, so every clip the addon may play has to be
named in a Lua file. Two sets exist:

  public  raw/public/<pool>/*  ->  sounds/<level>/<pool>/*.ogg        + Sounds.lua
  local   raw/local/<pool>/*   ->  sounds/local/<level>/<pool>/*.ogg  + SoundsLocal.lua

Pools are crit, hurt and small. The public set ships on CurseForge; the local
set (git-ignored, never packaged) holds clips that may not be redistributed.
If a set has no raw/<set>/small folder, the small uwus are derived from its
crit clips: shortened and about 12 dB quieter.

Every clip is trimmed to start right where its voice starts, made mono and loudness-
normalized, so no clip is much louder than the others, and cut to 2.5 s. PlaySoundFile has no
volume argument, so each clip is rendered once per volume level (LEVELS, in
percent) and the addon's volume slider picks the level.

Usage:  python tools/build_sounds.py [public|local ...]   (default: both)
Needs ffmpeg on PATH.
"""

import array
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
POOLS = ("crit", "hurt", "small")
RAW_EXT = {".wav", ".mp3", ".ogg", ".m4a", ".flac", ".webm", ".opus", ".aac"}
SETS = {
    "public": (ROOT / "raw" / "public", ROOT / "sounds", ROOT / "Sounds.lua"),
    "local": (ROOT / "raw" / "local", ROOT / "sounds" / "local", ROOT / "SoundsLocal.lua"),
}

# The sound must start with the floating text, so a clip starts where its voice
# does: the first sample within START_DB of its peak. Many clips have breath or
# noise up to 30 dB under the voice before or after it; reverb tails within 24 dB
# still count as a pause and are cut. PRE_ROLL before that point
# is kept and faded in, so soft consonants don't start with a click. The end is
# the last sample within END_DB of the peak, plus POST_ROLL faded out.
RATE = 44100
START_DB = -20
END_DB = -24
PRE_ROLL = 0.02
POST_ROLL = 0.03
# Clips with noise as loud as the voice in front of it, which no level threshold
# can tell apart: raw clip name -> second where the voice starts.
VOICE_START = {
    "uwu-discord-gorl-36357": 2.08,  # fan-like hiss before the uwu
}
NORMALIZE = "loudnorm=I=-16:TP=-1.5:LRA=11"
# A crit uwu must not ring on through the next fight: at most 2.5 s, faded out.
CAP = "atrim=0:2.5,afade=t=out:st=2.1:d=0.4"
# Small uwu: first 0.7 s, faded out, about 12 dB under a full one.
SMALL = "atrim=0:0.7,afade=t=out:st=0.5:d=0.2,volume=-12dB"
# Keep in sync with VOLUME_LEVELS in ForeverUwU.lua.
LEVELS = (20, 40, 60, 80, 100)


def ffmpeg(src, dst, filters):
    dst.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(
        # No tags from the source (titles, artists, comments) and no encoder tag either.
        ["ffmpeg", "-v", "error", "-y", "-i", str(src), "-vn", "-ac", "1", "-ar", "44100",
         "-map_metadata", "-1", "-map_metadata:s:a", "-1", "-fflags", "+bitexact", "-flags:a", "+bitexact", "-metadata:s:a", "encoder=",
         "-af", filters, "-c:a", "libvorbis", "-q:a", "4", str(dst)],
        check=True,
    )


def trim(src):
    """Returns the ffmpeg filters that cut src to its audible part."""
    pcm = subprocess.run(
        ["ffmpeg", "-v", "error", "-i", str(src), "-vn", "-ac", "1", "-ar", str(RATE), "-f", "f32le", "-"],
        capture_output=True, check=True,
    ).stdout
    samples = array.array("f", pcm)
    skip = int(VOICE_START.get(src.stem, 0) * RATE)
    peak = max(abs(x) for x in samples)
    loud = peak * 10 ** (START_DB / 20)
    audible = peak * 10 ** (END_DB / 20)
    first = next(i for i in range(skip, len(samples)) if abs(samples[i]) >= loud)
    last = next(i for i in range(len(samples) - 1, -1, -1) if abs(samples[i]) >= audible)
    start = max(skip / RATE, first / RATE - PRE_ROLL)
    end = min(len(samples) / RATE, last / RATE + POST_ROLL)
    fade_in = first / RATE - start
    return (
        f"atrim=start={start:.4f}:end={end:.4f},asetpts=PTS-STARTPTS,"
        f"afade=t=in:d={fade_in:.4f},afade=t=out:st={end - start - POST_ROLL:.4f}:d={POST_ROLL}"
    )


def build(name):
    raw_dir, out_dir, manifest = SETS[name]
    work = out_dir / "_full"
    for level in LEVELS:
        shutil.rmtree(out_dir / str(level), ignore_errors=True)
    shutil.rmtree(work, ignore_errors=True)

    # Full-volume masters first, then one copy per level.
    names = {}
    for pool in POOLS:
        sources = sorted(p for p in (raw_dir / pool).glob("*") if p.suffix.lower() in RAW_EXT)
        for src in sources:
            ffmpeg(src, work / pool / (src.stem + ".ogg"), f"{trim(src)},{CAP},{NORMALIZE}")
        names[pool] = [src.stem + ".ogg" for src in sources]
    if not names["small"]:
        for clip in names["crit"]:
            ffmpeg(work / "crit" / clip, work / "small" / clip, SMALL)
        names["small"] = list(names["crit"])

    for level in LEVELS:
        for pool in POOLS:
            for clip in names[pool]:
                ffmpeg(work / pool / clip, out_dir / str(level) / pool / clip, f"volume={level / 100:.2f}")
    shutil.rmtree(work, ignore_errors=True)

    # Lua strings need doubled backslashes: Interface\AddOns\...
    parts = ["Interface", "AddOns", "ForeverUwU", *out_dir.relative_to(ROOT).parts, "%d"]
    base = "\\\\".join(parts)
    lines = [
        "-- Generated by tools/build_sounds.py, don't edit by hand.",
        "-- %d is the volume level in percent.",
        "local _, ns = ...;",
        "ns.soundLists = ns.soundLists or {};",
        "ns.soundLists[#ns.soundLists + 1] = {",
        f'	set = "{name}",',
    ]
    for pool in POOLS:
        lines.append(f"\t{pool} = {{")
        for clip in sorted(names[pool]):
            lines.append(f'\t\t"{base}\\\\{pool}\\\\{clip}",')
        lines.append("\t},")
    lines.append("};")
    manifest.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")
    print(f"{name}: " + ", ".join(f"{len(names[p])} {p}" for p in POOLS) + f" x {len(LEVELS)} levels")


if __name__ == "__main__":
    for name in sys.argv[1:] or SETS:
        build(name)
