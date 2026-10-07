"""Generates images through the Vercel AI Gateway (art drafts for the logo and gallery).

Reads AI_GATEWAY_API_KEY from .env in the repo root (git-ignored) or the environment.

Usage:  python tools/gen_image.py <out_dir> <model> <n> "<prompt>"
Example models: openai/gpt-image-2, google/imagen-4.0-ultra-generate-001, bfl/flux-2-pro
"""

import base64
import json
import os
import sys
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
URL = "https://ai-gateway.vercel.sh/v1/images/generations"


def api_key():
    key = os.environ.get("AI_GATEWAY_API_KEY", "")
    env = ROOT / ".env"
    if not key and env.exists():
        for line in env.read_text(encoding="utf-8").splitlines():
            if line.startswith("AI_GATEWAY_API_KEY="):
                key = line.split("=", 1)[1].strip().strip('"')
    if not key:
        sys.exit("AI_GATEWAY_API_KEY missing (.env or environment)")
    return key


def main():
    out, model, n, prompt = Path(sys.argv[1]), sys.argv[2], int(sys.argv[3]), sys.argv[4]
    out.mkdir(parents=True, exist_ok=True)
    body = json.dumps({"model": model, "prompt": prompt, "n": n, "response_format": "b64_json"}).encode()
    req = urllib.request.Request(URL, data=body, method="POST", headers={
        "Authorization": f"Bearer {api_key()}", "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=300) as r:
            data = json.load(r)
    except urllib.error.HTTPError as e:
        sys.exit(f"{model}: HTTP {e.code} {e.read().decode('utf-8', 'replace')[:500]}")
    slug = model.replace("/", "_")
    for i, item in enumerate(data.get("data", []), 1):
        if item.get("b64_json"):
            path = out / f"{slug}_{len(list(out.glob(slug + '_*'))) + 1:02d}.png"
            path.write_bytes(base64.b64decode(item["b64_json"]))
            print(path)


if __name__ == "__main__":
    main()
