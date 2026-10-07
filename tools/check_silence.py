"""Reports leading and trailing quiet time of the built clips (sounds/100/*/*.ogg).

Quiet = more than THRESHOLD below the clip's own peak, so it works on noisy stream clips too.
Usage:  python tools/check_silence.py [threshold_db]   (default 30)
"""

import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
THRESHOLD = float(sys.argv[1]) if len(sys.argv) > 1 else 30


def edges(path):
    peak = float(re.search(r"max_volume: (-?[\d.]+)", subprocess.run(
        ["ffmpeg", "-i", str(path), "-af", "volumedetect", "-f", "null", "-"],
        capture_output=True, text=True).stderr).group(1))
    out = subprocess.run(
        ["ffmpeg", "-i", str(path), "-af", f"silencedetect=noise={peak - THRESHOLD}dB:d=0.03", "-f", "null", "-"],
        capture_output=True, text=True).stderr
    dur = float(re.search(r"Duration: (\d+):(\d+):([\d.]+)", out).group(3))
    starts = [float(x) for x in re.findall(r"silence_start: (-?[\d.]+)", out)]
    ends = [float(x) for x in re.findall(r"silence_end: ([\d.]+)", out)]
    lead = ends[0] if starts and starts[0] <= 0.01 and ends else 0.0
    tail = dur - starts[-1] if starts and (len(ends) < len(starts) or ends[-1] >= dur - 0.01) else 0.0
    return dur, lead, tail


if __name__ == "__main__":
    for clip in sorted((ROOT / "sounds" / "100").glob("*/*.ogg")):
        dur, lead, tail = edges(clip)
        flag = "  <-- pause" if lead > 0.08 or tail > 0.12 else ""
        print(f"{clip.parent.name:5} {clip.name[:44]:44} {dur:5.2f}s  lead {lead:4.2f}  tail {tail:4.2f}{flag}")
