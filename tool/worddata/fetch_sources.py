#!/usr/bin/env python3
"""Fetch the upstream resources used by the cue-pool build.

The app does not need this script at runtime.  Run it once on a machine with
network access, then run build_db.py and build_words.py.  Everything is cached
under tool/worddata/cache/ (git-ignored).

See LICENSES.md for the provenance and terms of each source.
"""
from __future__ import annotations

import json
import shutil
import subprocess
import sys
import time
import urllib.request
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent
CACHE = ROOT / "cache"
NLTK = CACHE / "nltk_data"
USER_AGENT = "cognitive-shuffler-worddata/1.0"


def download(url: str, target: Path, retries: int = 8) -> None:
    target.parent.mkdir(parents=True, exist_ok=True)
    if target.exists() and target.stat().st_size > 0:
        print(f"cached {target.relative_to(ROOT)}")
        return
    last_error: Exception | None = None
    for attempt in range(1, retries + 1):
        try:
            request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
            with urllib.request.urlopen(request, timeout=180) as response:
                partial = target.with_suffix(target.suffix + ".part")
                with partial.open("wb") as handle:
                    shutil.copyfileobj(response, handle, length=1024 * 1024)
                partial.replace(target)
            print(f"downloaded {target.relative_to(ROOT)}")
            return
        except Exception as error:  # noqa: BLE001 - network errors are expected
            last_error = error
            print(f"attempt {attempt}/{retries} failed for {url}: {error}")
            time.sleep(min(attempt * 2, 15))
    raise SystemExit(f"could not download {url}: {last_error}")


def extract_zip(path: Path, destination: Path) -> None:
    destination.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(path) as archive:
        archive.extractall(destination)


def mirror_urls(path: str) -> list[str]:
    return [
        f"https://fastly.jsdelivr.net/gh/nltk/nltk_data@gh-pages/{path}",
        f"https://gcore.jsdelivr.net/gh/nltk/nltk_data@gh-pages/{path}",
        f"https://cdn.jsdelivr.net/gh/nltk/nltk_data@gh-pages/{path}",
    ]


def fetch_first(urls: list[str], target: Path) -> None:
    error: Exception | None = None
    for url in urls:
        try:
            download(url, target)
            return
        except SystemExit as exception:
            error = exception
    raise SystemExit(f"all mirrors failed for {target}: {error}")


def organize_nltk() -> None:
    (NLTK / "corpora").mkdir(parents=True, exist_ok=True)
    (NLTK / "taggers").mkdir(parents=True, exist_ok=True)
    for name in ("wordnet", "brown", "cess_esp"):
        source = NLTK / name
        target = NLTK / "corpora" / name
        if source.is_dir() and not target.exists():
            source.rename(target)
    tagger = NLTK / "averaged_perceptron_tagger_eng"
    target = NLTK / "taggers" / "averaged_perceptron_tagger_eng"
    if tagger.is_dir() and not target.exists():
        tagger.rename(target)
    # NLTK 3.10 warns when the data directory is group/world writable.
    subprocess.run(["chmod", "-R", "go-w", str(NLTK)], check=False)


def fetch_nltk_data() -> None:
    packages = {
        "corpora/wordnet.zip": "wordnet.zip",
        "corpora/brown.zip": "brown.zip",
        "corpora/cess_esp.zip": "cess_esp.zip",
        "taggers/averaged_perceptron_tagger_eng.zip": "averaged_perceptron_tagger_eng.zip",
    }
    for remote, filename in packages.items():
        target = CACHE / filename
        fetch_first(mirror_urls(f"packages/{remote}"), target)
        extract_zip(target, NLTK)
    organize_nltk()


def fetch_frequency_words() -> None:
    for language in ("en", "es"):
        target = CACHE / f"{language}_50k.txt"
        urls = [
            f"https://fastly.jsdelivr.net/gh/hermitdave/FrequencyWords@master/content/2018/{language}/{language}_50k.txt",
            f"https://gcore.jsdelivr.net/gh/hermitdave/FrequencyWords@master/content/2018/{language}/{language}_50k.txt",
        ]
        fetch_first(urls, target)


def fetch_multiwordnet() -> None:
    if (CACHE / "mwn.db").exists():
        print("cached cache/mwn.db")
        return
    metadata = json.load(
        urllib.request.urlopen(
            urllib.request.Request(
                "https://pypi.org/pypi/multiwordnet/json",
                headers={"User-Agent": USER_AGENT},
            ),
            timeout=120,
        ),
    )
    wheels = [item for item in metadata["urls"] if item["filename"].endswith(".whl")]
    if not wheels:
        raise SystemExit("no MultiWordNet wheel found on PyPI")
    wheel = CACHE / wheels[0]["filename"]
    download(wheels[0]["url"], wheel)
    extract_zip(wheel, CACHE / "multiwordnet")


def fetch_ratings() -> None:
    download(
        "https://huggingface.co/datasets/StephanAkkerman/concreteness-ratings/resolve/main/concreteness_ratings.csv",
        CACHE / "concreteness" / "concreteness_en.csv",
    )
    target = CACHE / "concreteness" / "megahr.es"
    if target.exists():
        print("cached cache/concreteness/megahr.es")
        return
    try:
        from remotezip import RemoteZip
    except ImportError as error:
        raise SystemExit(
            "remotezip is required for the MEGAHit ratings: pip install remotezip"
        ) from error
    url = (
        "https://huggingface.co/datasets/"
        "FrancophonIA/Concreteness_and_imageability_lexicon/resolve/main/data.zip"
    )
    for attempt in range(1, 7):
        try:
            with RemoteZip(url) as archive:
                for name in ("megahr.es", "megahr.en"):
                    data = archive.read(name)
                    (CACHE / "concreteness" / name).write_bytes(data)
                    print(f"extracted {name} ({len(data)} bytes)")
            return
        except Exception as error:  # noqa: BLE001 - network errors
            print(f"attempt {attempt}/6 failed for MEGAHit: {error}")
            time.sleep(attempt * 2)
    raise SystemExit("could not download the MEGAHit ratings")


def main() -> None:
    CACHE.mkdir(parents=True, exist_ok=True)
    print("NLTK data")
    fetch_nltk_data()
    print("frequency lists")
    fetch_frequency_words()
    print("MultiWordNet")
    fetch_multiwordnet()
    print("concreteness ratings")
    fetch_ratings()
    print("\nDone. Next:")
    print("  python3 tool/worddata/build_db.py")
    print("  python3 tool/worddata/build_words.py")


if __name__ == "__main__":
    main()
