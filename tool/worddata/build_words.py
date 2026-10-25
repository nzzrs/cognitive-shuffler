#!/usr/bin/env python3
"""Build the bundled cue-word pools for English and Spanish.

The app never contains hand-written cue words.  This script derives them from
open lexical resources and writes deterministic JSON assets:

  assets/words/en.json
  assets/words/es.json

Inputs (see fetch_sources.py) are cached under tool/worddata/cache/:

  nltk_data/                 WordNet 3.0, Brown, CESS-ESP, POS tagger
  en_50k.txt, es_50k.txt     FrequencyWords (OpenSubtitles 2018)
  mwn.db                     MultiWordNet (English + Spanish synsets)
  concreteness_en.csv        Brysbaert et al. (2014) English ratings
  concreteness/megahr.es     MEGAHit multilingual concreteness predictions

Selection rules:
  * nouns only, middle frequency band, readable length;
  * English: first WordNet sense must be a physical entity and the word's
    dominant part of speech in Brysbaert must be "Noun";
  * Spanish: the word must be a MultiWordNet noun, rated concrete/imageable,
    and map to a concrete WordNet concept;
  * emotionally loaded, medical, violent, sexual, religious, working, urban,
    technological and generic words are removed through denylist.json.
"""
from __future__ import annotations

import argparse
import collections
import csv
import json
import math
import random
import re
import sqlite3
from dataclasses import dataclass
from datetime import date
from pathlib import Path

import nltk
from nltk import pos_tag
from nltk.corpus import brown, cess_esp, wordnet as wn

ROOT = Path(__file__).resolve().parents[2]
DATA = Path(__file__).resolve().parent
CACHE = DATA / "cache"
ASSETS = ROOT / "assets" / "words"

nltk.data.path.insert(0, str(CACHE / "nltk_data"))

ALLOWED_LEXNAMES = {
    "noun.artifact",
    "noun.animal",
    "noun.food",
    "noun.location",
    "noun.object",
    "noun.plant",
    "noun.substance",
    "noun.phenomenon",
}

# English ratings: accepted range.  Brysbaert is on a 1..5 scale.
EN_MIN_CONCRETENESS = 4.0
EN_MIN_KNOWN = 0.9
# Spanish predictions from MEGAHit, also 1..5.
ES_MIN_CONCRETENESS = 3.65
ES_MIN_IMAGEABILITY = 4.0

MIN_ZIPF = 3.5
MAX_ZIPF = 6.5
MAX_WORDS = 4000

# A few highly concrete concepts sit outside WordNet's physical-entity tree
# (books are communication, forests are collectives).  They are explicitly
# allowed by synset, never by word.
EXTRA_CONCRETE_SYNSETS = {
    "book.n.01",
    "forest.n.01",
    "woods.n.01",
    "grove.n.01",
    "orchard.n.01",
    "meadow.n.01",
    "pasture.n.01",
    "village.n.01",
}

PROPER_SUBTREES = (
    "weapon.n.01",
    "disease.n.01",
    "person.n.01",
    "group.n.01",
    "money.n.01",
    "corpse.n.01",
)

# Ancestors are checked from the synset upwards.  The first match wins, which
# keeps e.g. "car" a vehicle instead of a container while "bottle" stays a
# container.  The mapping deliberately stays small: the goal is enough
# categories for semantic spacing, not a taxonomy.
CATEGORY_ANCESTORS = {
    "seat.n.01": "furniture",
    "furniture.n.01": "furniture",
    "bedroom_furniture.n.01": "furniture",
    "tableware.n.01": "tableware",
    "cutlery.n.02": "tableware",
    "container.n.01": "container",
    "garment.n.01": "clothing",
    "footwear.n.01": "clothing",
    "headdress.n.01": "clothing",
    "clothing.n.01": "clothing",
    "building.n.01": "building",
    "room.n.01": "building",
    "motor_vehicle.n.01": "vehicle",
    "craft.n.02": "vehicle",
    "vehicle.n.01": "vehicle",
    "tool.n.01": "tool",
    "utensil.n.01": "tool",
    "musical_instrument.n.01": "instrument",
    "game_equipment.n.01": "toy",
    "plaything.n.01": "toy",
    "jewelry.n.01": "jewelry",
    "fabric.n.01": "fabric",
    "plot.n.02": "garden",
    "garden.n.01": "garden",
    "body_of_water.n.01": "water",
    "geological_formation.n.01": "landscape",
    "land.n.01": "landscape",
    "weather.n.01": "weather",
    "atmosphere.n.01": "sky",
    "celestial_body.n.01": "sky",
    "publication.n.01": "book",
    "forest.n.01": "forest",
    "grove.n.01": "forest",
    "orchard.n.01": "garden",
    "meadow.n.01": "landscape",
    "pasture.n.01": "landscape",
    "village.n.01": "village",
    "road.n.01": "road",
    "way.n.01": "road",
    "structure.n.01": "building",
    "barrier.n.01": "fence",
}

LEXNAME_FALLBACK = {
    "noun.artifact": "object",
    "noun.animal": "animal",
    "noun.food": "food",
    "noun.location": "place",
    "noun.object": "object",
    "noun.plant": "plant",
    "noun.substance": "substance",
    "noun.phenomenon": "weather",
}


@dataclass(frozen=True)
class Word:
    word: str
    zipf: float
    category: str
    synset: str


def log(message: str) -> None:
    print(message, flush=True)


def closure(root) -> set:
    seen: set = set()
    stack = [root]
    while stack:
        synset = stack.pop()
        if synset in seen:
            continue
        seen.add(synset)
        stack.extend(synset.hyponyms())
    return seen


def load_frequencies(path: Path) -> tuple[dict[str, int], int]:
    counts: dict[str, int] = {}
    total = 0
    with path.open(encoding="utf-8") as handle:
        for line in handle:
            parts = line.split()
            if len(parts) != 2:
                continue
            word, raw = parts[0].lower(), int(parts[1])
            counts[word] = counts.get(word, 0) + raw
            total += raw
    return counts, total


def zipf(count: int, total: int) -> float:
    if count <= 0:
        return 0.0
    return math.log10(count / total * 1e9)


def load_noun_share(tagged, is_noun) -> tuple[collections.Counter, collections.Counter]:
    nouns: collections.Counter = collections.Counter()
    totals: collections.Counter = collections.Counter()
    for word, tag in tagged:
        key = word.lower()
        totals[key] += 1
        if is_noun(tag):
            nouns[key] += 1
    return nouns, totals


def english_noun_share(word: str, nouns, totals) -> float | None:
    total = totals.get(word, 0)
    if total >= 4:
        return nouns.get(word, 0) / total
    tag = pos_tag(["the", word])[1][1]
    return 1.0 if tag in ("NN", "NNS") else 0.0


def spanish_noun_share(word: str, nouns, totals) -> float | None:
    total = totals.get(word, 0)
    if total == 0:
        return None
    return nouns.get(word, 0) / total


def category_for(synset) -> str:
    for ancestor in reversed(synset.hypernym_paths()[0]):
        mapped = CATEGORY_ANCESTORS.get(ancestor.name())
        if mapped:
            return mapped
    if synset.lexname() == "noun.artifact":
        parents = synset.hypernyms()
        if parents:
            label = parents[0].name().split(".")[0].replace("_", " ")
            if label not in {"artifact", "instrumentality", "whole", "object"}:
                return label
    return LEXNAME_FALLBACK.get(synset.lexname(), "object")


def load_brysbaert() -> dict[str, tuple[float, str, float]]:
    ratings: dict[str, tuple[float, str, float]] = {}
    path = CACHE / "concreteness" / "concreteness_en.csv"
    with path.open(encoding="utf-8", newline="") as handle:
        for row in csv.DictReader(handle):
            try:
                ratings[row["Word"].lower()] = (
                    float(row["Conc.M"]),
                    row["Dom_Pos"],
                    float(row["Percent_known"]),
                )
            except (KeyError, ValueError):
                continue
    return ratings


def load_megahr(language: str) -> dict[str, tuple[float, float]]:
    ratings: dict[str, tuple[float, float]] = {}
    path = CACHE / "concreteness" / f"megahr.{language}"
    if not path.exists():
        return ratings
    with path.open(encoding="utf-8") as handle:
        for line in handle:
            parts = line.rstrip("\n").split("\t")
            if len(parts) < 3:
                continue
            try:
                ratings[parts[0].lower()] = (float(parts[1]), float(parts[2]))
            except ValueError:
                continue
    return ratings


def load_denylist() -> dict[str, set[str]]:
    raw = json.loads((DATA / "denylist.json").read_text(encoding="utf-8"))
    result: dict[str, set[str]] = {"en": set(), "es": set()}
    for key, value in raw.items():
        if key == "_comment":
            continue
        for language in ("en", "es"):
            result[language].update(value.get(language, []))
    return result


def build_physical_set() -> set:
    physical = closure(wn.synset("physical_entity.n.01"))
    excluded: set = set()
    for name in PROPER_SUBTREES:
        try:
            excluded |= closure(wn.synset(name))
        except nltk.corpus.reader.wordnet.WordNetError:
            continue
    return physical - excluded


def is_concrete(synset) -> bool:
    if synset.name() in EXTRA_CONCRETE_SYNSETS:
        return True
    return synset.lexname() in ALLOWED_LEXNAMES and synset in CONCRETE_SYNSETS


def english_words(
    frequencies: dict[str, int],
    total: int,
    brysbaert: dict[str, tuple[float, str, float]],
    nouns,
    noun_totals,
    denied: set[str],
) -> dict[str, Word]:
    found: dict[str, Word] = {}
    for raw in set(wn.all_lemma_names(pos="n")):
        word = raw.lower()
        if not re.fullmatch(r"[a-z]{3,11}", word):
            continue
        score = zipf(frequencies.get(word, 0), total)
        if not (MIN_ZIPF <= score <= MAX_ZIPF):
            continue
        rating = brysbaert.get(word)
        if not rating:
            continue
        concreteness, dominant, known = rating
        if dominant != "Noun" or concreteness < EN_MIN_CONCRETENESS or known < EN_MIN_KNOWN:
            continue
        senses = wn.synsets(word, pos="n")
        if not senses or not is_concrete(senses[0]):
            continue
        share = english_noun_share(word, nouns, noun_totals)
        if share is None or share < 0.5:
            continue
        singular = wn.morphy(word, "n")
        if singular and singular != word and wn.synsets(singular, pos="n"):
            continue
        if word in denied or word in found:
            continue
        primary = senses[0]
        found[word] = Word(word, round(score, 2), category_for(primary), primary.name())
    return found


def build_spanish_index() -> tuple[
    dict[str, set[str]], dict[str, list[str]], dict[str, list[str]], dict[str, float]
]:
    database = CACHE / "mwn.db"
    if not database.exists():
        raise SystemExit("cache/mwn.db is missing; run build_db.py first")
    connection = sqlite3.connect(database)
    cursor = connection.cursor()

    synsets: dict[str, set[str]] = collections.defaultdict(set)
    for synset_id, lemma in cursor.execute(
        "select id, lemma from spanish_lemma where pos='n' and is_phrase='N'"
    ):
        synsets[lemma.lower()].add(synset_id)

    english_lemmas: dict[str, list[str]] = {}
    for synset_id, raw in cursor.execute(
        "select id, word from english_synset where id like 'n#%'"
    ):
        english_lemmas[synset_id] = [part for part in (raw or "").split() if part]

    semfields: dict[str, list[str]] = collections.defaultdict(list)
    for synset_id, label in cursor.execute("select synset, english from semfield"):
        semfields[synset_id].append(label)

    sentiment: dict[str, float] = {}
    for synset_id, pos, neg, obj in cursor.execute(
        "select syn, pos, neg, obj from common_sentiment where syn like 'n#%'"
    ):
        try:
            sentiment[synset_id] = float(obj) - max(float(pos), float(neg))
        except ValueError:
            continue

    connection.close()
    return synsets, english_lemmas, semfields, sentiment


def spanish_words(
    frequencies: dict[str, int],
    total: int,
    ratings: dict[str, tuple[float, float]],
    nouns,
    noun_totals,
    denied: set[str],
) -> dict[str, Word]:
    synsets, english_lemmas, _, _ = build_spanish_index()
    found: dict[str, Word] = {}

    for word, synset_ids in synsets.items():
        if not re.fullmatch(r"[a-záéíóúüñ]{3,12}", word):
            continue
        score = zipf(frequencies.get(word, 0), total)
        if not (MIN_ZIPF <= score <= MAX_ZIPF):
            continue
        rating = ratings.get(word)
        if not rating:
            continue
        concreteness, imageability = rating
        if concreteness < ES_MIN_CONCRETENESS or imageability < ES_MIN_IMAGEABILITY:
            continue

        share = spanish_noun_share(word, nouns, noun_totals)
        if share is not None and share < 0.5:
            continue
        if share is None and concreteness < 4.0:
            continue
        if word in denied or word in found:
            continue

        best: tuple[float, object] | None = None
        for synset_id in synset_ids:
            lemmas = english_lemmas.get(synset_id, [])
            if not lemmas:
                continue
            senses = wn.synsets(lemmas[0].lower().replace("_", " "), pos="n")
            if not senses or not is_concrete(senses[0]):
                continue
            support = max(
                zipf(english_counts.get(lemma.lower().replace("_", " "), 0), english_total)
                for lemma in lemmas[:4]
            )
            if best is None or support > best[0]:
                best = (support, senses[0])
        if best is None:
            continue
        synset = best[1]
        found[word] = Word(word, round(score, 2), category_for(synset), synset.name())

    # Prefer singular forms when both plural and singular made the cut.
    for word in sorted(found):
        if not word.endswith("s") or len(word) <= 4:
            continue
        for singular in (word[:-1], word[:-2]):
            if singular in found and singular != word:
                del found[word]
                break
    return found


def write_asset(language: str, words: dict[str, Word]) -> None:
    ordered = sorted(words.values(), key=lambda item: item.word)
    payload = {
        "language": language,
        "version": 1,
        "license": "CC-BY-SA-4.0",
        "generated": date.today().isoformat(),
        "sources": [
            "Princeton WordNet 3.0 (Princeton WordNet License)",
            "FrequencyWords / OpenSubtitles 2018 (CC-BY-SA-4.0)",
            "Brysbaert et al. 2014 concreteness ratings (MIT mirror)",
            "MEGAHit concreteness/imageability lexicon (CC-BY-SA-4.0)",
            "MultiWordNet Spanish WordNet (CC-BY-SA-4.0)",
        ],
        "words": [
            {"w": item.word, "c": item.category, "z": item.zipf} for item in ordered
        ],
    }
    target = ASSETS / f"{language}.json"
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(
        json.dumps(payload, ensure_ascii=False, separators=(",", ":")) + "\n",
        encoding="utf-8",
    )
    log(f"wrote {target.relative_to(ROOT)} ({len(ordered)} words)")


def write_report(
    english: dict[str, Word], spanish: dict[str, Word], denied: dict[str, set[str]]
) -> None:
    lines = [
        "# Generated cue pools",
        "",
        f"Generated {date.today().isoformat()} by `tool/worddata/build_words.py`.",
        "",
        "These files are generated data, not hand-written code.  The build script is",
        "deterministic and is the only place where word selection rules live.",
        "",
        "## Counts",
        "",
        f"- English: **{len(english)}** words",
        f"- Spanish: **{len(spanish)}** words",
        f"- Denylisted English entries: {len(denied['en'])}",
        f"- Denylisted Spanish entries: {len(denied['es'])}",
        "",
        "## Categories",
        "",
    ]
    for language, words in (("English", english), ("Spanish", spanish)):
        counts = collections.Counter(word.category for word in words.values())
        lines.append(f"### {language}")
        lines.append("")
        for category, count in counts.most_common():
            lines.append(f"- {category}: {count}")
        lines.append("")
        lines.append(
            "Sample: "
            + ", ".join(
                sorted(random.Random(7).sample(sorted(words), min(40, len(words))))
            )
        )
        lines.append("")
    lines += [
        "## Sources",
        "",
        "- FrequencyWords, OpenSubtitles 2018, CC-BY-SA-4.0",
        "- Princeton WordNet 3.0, Princeton WordNet License",
        "- MultiWordNet / Spanish WordNet, CC-BY-SA-4.0",
        "- Brysbaert et al. (2014) concreteness ratings",
        "- MEGAHit concreteness and imageability predictions (CLARIN)",
        "",
        "Word lists are released under CC-BY-SA-4.0 together with this app.",
        "",
    ]
    (DATA / "report.md").write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--seed", type=int, default=1234)
    args = parser.parse_args()
    random.seed(args.seed)

    global CONCRETE_SYNSETS, english_counts, english_total, frequencies_en
    CONCRETE_SYNSETS = build_physical_set()
    log(f"concrete physical synsets: {len(CONCRETE_SYNSETS)}")

    english_counts, english_total = load_frequencies(CACHE / "en_50k.txt")
    spanish_counts, spanish_total = load_frequencies(CACHE / "es_50k.txt")

    english_nouns, english_totals = load_noun_share(
        brown.tagged_words(), lambda tag: tag in ("NN", "NNS")
    )
    spanish_nouns, spanish_totals = load_noun_share(
        cess_esp.tagged_words(), lambda tag: tag.startswith("nc")
    )

    brysbaert = load_brysbaert()
    spanish_ratings = load_megahr("es")
    denied = load_denylist()

    english = english_words(
        english_counts,
        english_total,
        brysbaert,
        english_nouns,
        english_totals,
        denied["en"],
    )
    spanish = spanish_words(
        spanish_counts,
        spanish_total,
        spanish_ratings,
        spanish_nouns,
        spanish_totals,
        denied["es"],
    )
    log(f"selected English: {len(english)}")
    log(f"selected Spanish: {len(spanish)}")

    if len(english) < 300 or len(spanish) < 300:
        raise SystemExit("refusing to write an implausibly small pool")

    write_asset("en", english)
    write_asset("es", spanish)
    write_report(english, spanish, denied)


if __name__ == "__main__":
    main()
